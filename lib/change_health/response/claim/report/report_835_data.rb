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

        def report_creation_date
          payments.map(&:report_creation_date).min
        end

        def claims
          payments.flat_map(&:claims).compact
        end

        def payments
          report_payments = []

          transactions&.each do |transaction|
            payment_id = transaction.dig('id')
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
              claim_id = detail_info.dig('id')
              detail_info['paymentInfo']&.map do |payment_info|
                claim_payment_amount = payment_info.dig('claimPaymentInfo', 'claimPaymentAmount')
                claim_status_code = payment_info.dig('claimPaymentInfo', 'claimStatusCode')
                patient_control_number = payment_info.dig('claimPaymentInfo', 'patientControlNumber')
                patient_first_name = payment_info.dig('patientName', 'firstName')
                patient_last_name = payment_info.dig('patientName', 'lastName')
                patient_member_id =
                  presence(payment_info.dig('patientName', 'memberId')) ||
                  presence(payment_info.dig('subscriber', 'memberId'))
                payer_claim_control_number = payment_info.dig('claimPaymentInfo', 'payerClaimControlNumber')
                service_provider_npi =
                  presence(payment_info.dig('renderingProvider', 'npi')) ||
                  presence(detail_info.dig('providerSummaryInformation', 'providerIdentifier')) ||
                  presence(transaction.dig('payee', 'npi'))
                total_charge_amount = payment_info.dig('claimPaymentInfo', 'totalClaimChargeAmount')

                claim_payment_remark_codes = []
                claim_payment_remark_codes_index = 1

                loop do
                  current_claim_payment_remark_code = payment_info
                                                      .dig(
                                                        'outpatientAdjudication',
                                                        "claimPaymentRemarkCode#{claim_payment_remark_codes_index}"
                                                      )
                  break unless presence(current_claim_payment_remark_code)

                  claim_payment_remark_codes << current_claim_payment_remark_code
                  claim_payment_remark_codes_index += 1
                end

                claim_adjustments = adjustments(payment_info['claimAdjustments'])

                service_date_begin = nil
                service_date_end = nil
                service_lines = payment_info['serviceLines']&.map do |service_line|
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

                  health_care_check_remark_codes = presence(service_line['healthCareCheckRemarkCodes']&.filter_map do |health_care_check_remark_code|
                    remark_code = health_care_check_remark_code['remarkCode']
                    next unless presence(remark_code)

                    Report835HealthCareCheckRemarkCode.new(
                      code_list_qualifier_code: health_care_check_remark_code['codeListQualifierCode'],
                      code_list_qualifier_code_value: health_care_check_remark_code['codeListQualifierCodeValue'],
                      remark_code: remark_code
                    )
                  end)

                  Report835ServiceLine.new(
                    adjudicated_procedure_code: adjudicated_procedure_code,
                    allowed_actual: allowed_actual,
                    line_item_charge_amount: line_item_charge_amount,
                    line_item_provider_payment_amount: line_item_provider_payment_amount,
                    service_adjustments: service_adjustments,
                    health_care_check_remark_codes: health_care_check_remark_codes
                  )
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
                  id: claim_id,
                  patient_control_number: patient_control_number,
                  patient_first_name: patient_first_name,
                  patient_last_name: patient_last_name,
                  patient_member_id: patient_member_id,
                  payer_claim_control_number: payer_claim_control_number,
                  payer_identification: payer_identification,
                  payer_name: payer_name,
                  report_creation_date: report_creation_date,
                  report_name: report_name,
                  service_date_begin: service_date_begin,
                  service_date_end: service_date_end,
                  service_lines: service_lines,
                  service_provider_npi: service_provider_npi,
                  total_charge_amount: total_charge_amount
                )
              end
            end
            report_payments << Report835Payment.new(
              check_issue_or_eft_effective_date: check_issue_or_eft_effective_date,
              check_or_eft_trace_number: check_or_eft_trace_number,
              claims: claims,
              id: payment_id,
              payer_identifier: payer_identifier,
              payer_name: payer_name,
              payer_address: payer_address,
              payment_method_code: payment_method_code,
              provider_adjustments: provider_adjustments,
              report_creation_date: report_creation_date,
              report_name: report_name,
              total_actual_provider_payment_amount: total_actual_provider_payment_amount
            )
          end

          report_payments
        end

        private

        def adjustments(list)
          presence(list&.filter_map do |adjustment|
            adjustments = {}
            adjustment_index = 1
            loop do
              current_adjustment_reason = adjustment["adjustmentReasonCode#{adjustment_index}"]
              break unless presence(current_adjustment_reason)

              adjustment_amount = adjustment["adjustmentAmount#{adjustment_index}"]
              adjustments[current_adjustment_reason] = adjustment_amount
              adjustment_index += 1
            end

            claim_adjustment_group_code = adjustment['claimAdjustmentGroupCode']

            if presence(adjustments)
              Report835ServiceAdjustment.new(
                adjustments: adjustments,
                claim_adjustment_group_code: claim_adjustment_group_code
              )
            end
          end)
        end
      end
    end
  end
end
