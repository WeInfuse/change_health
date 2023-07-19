module ChangeHealth
  module Response
    module Claim
      # Methods only return meaningful data for json reports
      class Report835Data < ChangeHealth::Response::Claim::ReportData
        def transactions
          @raw['transactions']
        end

        def payer_identification
          transactions&.first&.dig('payer', 'payerIdentificationNumber')
        end

        # Only one payer per report
        def payer_name
          transactions&.first&.dig('payer')&.dig('name')
        end

        def payer_state
          transactions&.first&.dig('payer')&.dig('address', 'state')
        end

        def payee_npi
          transactions&.first&.dig('payee')&.dig('npi')
        end

        def payee_name
          transactions&.first&.dig('payee')&.dig('name')
        end

        def payee_tin
          transactions&.first&.dig('payee')&.dig('federalTaxPayersIdentificationNumber')
        end

        def payer_phone_number
          transactions&.first&.dig('payer', 'technicalContactInformation')&.collect{|c| c.dig('contactMethods') }&.flatten&.last&.dig('phone')
        end

        def report_creation_date
          payments.map(&:report_creation_date).min
        end

        def claims
          payments.flat_map(&:claims).compact
        end

        def payments
          report_payments = []

          transactions&.each do |transaction|
            check_or_eft_trace_number = transaction.dig('paymentAndRemitReassociationDetails', 'checkOrEFTTraceNumber')
            check_issue_or_eft_effective_date =
              ChangeHealth::Models::PARSE_DATE.call(
                transaction.dig('financialInformation', 'checkIssueOrEFTEffectiveDate')
              )

            payer_identifier = transaction.dig('financialInformation', 'payerIdentifier')
            payment_method_code = transaction.dig('financialInformation', 'paymentMethodCode')
            payer_address = transaction.dig('payer', 'address')
            provider_adjustments = transaction['providerAdjustments']&.map do |provider_adjustment|
              adjustments = provider_adjustment['adjustments']&.map do |adjustment|
                {
                  amount: adjustment['providerAdjustmentAmount'],
                  identifier: adjustment['providerAdjustmentIdentifier'],
                  reason_code: adjustment['adjustmentReasonCode']
                }
              end
              Report835ProviderAdjustment.new(
                adjustments: adjustments,
                fiscal_period_date: ChangeHealth::Models::PARSE_DATE.call(provider_adjustment['fiscalPeriodDate']),
                provider_identifier: provider_adjustment['providerIdentifier']
              )
            end

            report_creation_date = ChangeHealth::Models::PARSE_DATE.call(transaction['productionDate'])
            total_actual_provider_payment_amount =
              transaction.dig('financialInformation', 'totalActualProviderPaymentAmount')
            claims = transaction['detailInfo']&.flat_map do |detail_info|
              detail_info['paymentInfo']&.map do |payment_info|
                claim_payment_amount = payment_info.dig('claimPaymentInfo', 'claimPaymentAmount')
                claim_status_code = payment_info.dig('claimPaymentInfo', 'claimStatusCode')
                claim_frequency_code = payment_info.dig('claimPaymentInfo', 'claimFrequencyCode')
                patient_control_number = payment_info.dig('claimPaymentInfo', 'patientControlNumber')
                patient_first_name = payment_info.dig('patientName', 'firstName')
                patient_last_name = payment_info.dig('patientName', 'lastName')


                patient_member_id =
                  payment_info.dig('patientName', 'memberId') ||
                  payment_info.dig('subscriber', 'memberId')
                payer_claim_control_number = payment_info.dig('claimPaymentInfo', 'payerClaimControlNumber')
                
                filing_indicator_code = payment_info.dig('claimPaymentInfo', 'claimFilingIndicatorCode')
                rendering_provider_npi = payment_info.dig('renderingProvider', 'npi') || payment_info['serviceLines'].first.dig('renderingProviderInformation','npi')
                claim_received_date = ChangeHealth::Models::PARSE_DATE.call(payment_info.dig('claimReceivedDate'))
                service_provider_npi =
                  payment_info.dig('renderingProvider', 'npi') ||
                  detail_info.dig('providerSummaryInformation', 'providerIdentifier') ||
                  transaction.dig('payee', 'npi')
                total_charge_amount = payment_info.dig('claimPaymentInfo', 'totalClaimChargeAmount')
                patient_responsibility_amount = payment_info.dig('claimPaymentInfo', 'patientResponsibilityAmount')

                claim_payment_remark_codes = []
                claim_payment_remark_codes_index = 1
                while payment_info.dig('outpatientAdjudication',
                                       "claimPaymentRemarkCode#{claim_payment_remark_codes_index}")
                  claim_payment_remark_codes << payment_info.dig('outpatientAdjudication',
                                                                 "claimPaymentRemarkCode#{claim_payment_remark_codes_index}")
                  claim_payment_remark_codes_index += 1
                end

                claim_adjustments = adjustments(payment_info['claimAdjustments'])

                service_date_begin = nil
                service_date_end = nil
                provider_control_number = nil
                service_lines = payment_info['serviceLines']&.map do |service_line|
                  provider_control_number = service_line.dig('providerControlNumber') if service_line.dig('providerControlNumber')
                  service_line_date = ChangeHealth::Models::PARSE_DATE.call(service_line['serviceDate'])
                  unless service_line_date.nil?
                    if service_date_begin.nil? || service_line_date < service_date_begin
                      service_date_begin = service_line_date
                    end
                    if service_date_end.nil? || service_date_end < service_line_date
                      service_date_end = service_line_date
                    end
                  end

                  adjudicated_procedure_code = service_line.dig('servicePaymentInformation', 'adjudicatedProcedureCode')
                  allowed_actual = service_line.dig('serviceSupplementalAmounts', 'allowedActual')
                  line_item_charge_amount = service_line.dig('servicePaymentInformation', 'lineItemChargeAmount')
                  line_item_provider_payment_amount = service_line.dig('servicePaymentInformation',
                                                                       'lineItemProviderPaymentAmount')

                  service_adjustments = adjustments(service_line['serviceAdjustments'])
                  provider_control_number = service_line.dig('providerControlNumber')

                  health_care_check_remark_codes = service_line['healthCareCheckRemarkCodes']&.map do |health_care_check_remark_code|
                    Report835HealthCareCheckRemarkCode.new(
                      code_list_qualifier_code: health_care_check_remark_code['codeListQualifierCode'],
                      code_list_qualifier_code_value: health_care_check_remark_code['codeListQualifierCodeValue'],
                      remark_code: health_care_check_remark_code['remarkCode']
                    )
                  end

                  Report835ServiceLine.new(
                    adjudicated_procedure_code: adjudicated_procedure_code,
                    allowed_actual: allowed_actual,
                    line_item_charge_amount: line_item_charge_amount,
                    line_item_provider_payment_amount: line_item_provider_payment_amount,
                    service_adjustments: service_adjustments,
                    provider_control_number: provider_control_number,
                    health_care_check_remark_codes: health_care_check_remark_codes
                  )
                end

                class_of_contract_code = payment_info.dig('otherClaimRelatedIdentification', 'classOfContractCode')
                group_or_policy_number = payment_info.dig('otherClaimRelatedIdentification', 'groupOrPolicyNumber')

                claim_supplemental_information = payment_info['claimSupplementalInformation']
                raw_service_lines = payment_info['serviceLines']&.map do |service_line|
                  service_line
                end

                if service_date_begin.nil? && service_date_end.nil?
                  service_date_begin = ChangeHealth::Models::PARSE_DATE.call(payment_info['claimStatementPeriodStart'])
                  service_date_end = ChangeHealth::Models::PARSE_DATE.call(payment_info['claimStatementPeriodEnd'])
                end

                Report835Claim.new(
                  claim_adjustments: claim_adjustments,
                  claim_payment_amount: claim_payment_amount,
                  claim_payment_remark_codes: claim_payment_remark_codes,
                  claim_status_code: claim_status_code,
                  patient_control_number: patient_control_number,
                  patient_first_name: patient_first_name,
                  patient_last_name: patient_last_name,
                  patient_member_id: patient_member_id,
                  payer_claim_control_number: payer_claim_control_number,
                  payer_identification: payer_identification,
                  payer_name: payer_name,
                  report_creation_date: report_creation_date,
                  report_name: report_name,
                  class_of_contract_code: class_of_contract_code,
                  group_or_policy_number: group_or_policy_number,
                  service_date_begin: service_date_begin,
                  service_date_end: service_date_end,
                  service_lines: service_lines,
                  provider_control_number: provider_control_number,
                  raw_service_lines: raw_service_lines,
                  service_provider_npi: service_provider_npi,
                  total_charge_amount: total_charge_amount,
                  patient_responsibility_amount: patient_responsibility_amount,
                  claim_supplemental_information: claim_supplemental_information,
                  payee_npi: payee_npi,
                  filing_indicator_code: filing_indicator_code,
                  payee_name: payee_name,
                  payee_tin: payee_tin,
                  rendering_provider_npi: rendering_provider_npi,
                  payer_state: payer_state,
                  payment_method_code: payment_method_code,
                  claim_received_date: claim_received_date,
                  claim_frequency_code: claim_frequency_code
                )
              end
            end
            report_payments << Report835Payment.new(
              check_issue_or_eft_effective_date: check_issue_or_eft_effective_date,
              check_or_eft_trace_number: check_or_eft_trace_number,
              claims: claims,
              payer_identifier: payer_identifier,
              payer_name: payer_name,
              payer_address: payer_address,
              payment_method_code: payment_method_code,
              provider_adjustments: provider_adjustments,
              report_creation_date: report_creation_date,
              report_name: report_name,
              payer_phone_number: payer_phone_number,
              total_actual_provider_payment_amount: total_actual_provider_payment_amount
            )
          end

          report_payments
        end

        private

        def adjustments(list)
          list&.map do |adjustment|
            adjustments = {}
            service_adjustment_index = 1
            while adjustment["adjustmentReasonCode#{service_adjustment_index}"]
              adjustment_reason = adjustment["adjustmentReasonCode#{service_adjustment_index}"]
              adjustment_amount = adjustment["adjustmentAmount#{service_adjustment_index}"]
              adjustments[adjustment_reason] = adjustment_amount
              service_adjustment_index += 1
            end

            claim_adjustment_group_code = adjustment['claimAdjustmentGroupCode']
            claim_adjustment_group_code_value = adjustment['claimAdjustmentGroupCodeValue']

            Report835ServiceAdjustment.new(
              adjustments: adjustments,
              claim_adjustment_group_code: claim_adjustment_group_code,
              claim_adjustment_group_code_value: claim_adjustment_group_code_value
            )
          end
        end
      end
    end
  end
end
