module ChangeHealth
  module Response
    module Claim
      # Methods only return meaningful data for json reports
      class Report835Data < ChangeHealth::Response::Claim::ReportData
        def transactions
          @raw['transactions']
        end

        # Only one payer per report
        def payer_name
          transactions&.first&.dig('payer')&.dig('name')
        end

        def payment_method_code
          transactions&.first&.dig('financialInformation', 'paymentMethodCode')
        end

        def report_creation_date
          ChangeHealth::Models::PARSE_DATE.call(transactions&.first&.dig('productionDate'))
        end

        def total_actual_provider_payment_amount
          transactions&.first&.dig('financialInformation', 'totalActualProviderPaymentAmount')
        end

        def claims
          report_claims = []

          transactions&.each do |transaction|
            payment_method_code = transaction.dig('financialInformation', 'paymentMethodCode')
            payer_name = transaction.dig('payer', 'name')
            payer_identification = transaction.dig('payer', 'payerIdentificationNumber')
            report_creation_date = ChangeHealth::Models::PARSE_DATE.call(transaction['productionDate'])
            total_actual_provider_payment_amount = transaction.dig('financialInformation',
                                                                   'totalActualProviderPaymentAmount')

            transaction['detailInfo']&.each do |detail_info|
              detail_info['paymentInfo']&.each do |payment_info|
                patient_first_name = payment_info.dig('patientName', 'firstName')
                patient_last_name = payment_info.dig('patientName', 'lastName')
                service_provider_npi = payment_info.dig('renderingProvider', 'npi')
                total_charge_amount = payment_info.dig('claimPaymentInfo', 'totalClaimChargeAmount')
                payer_claim_control_number = payment_info.dig('claimPaymentInfo', 'payerClaimControlNumber')

                service_date_begin = nil
                service_date_end = nil
                service_lines = []
                payment_info['serviceLines']&.each do |service_line|
                  service_line_date = ChangeHealth::Models::PARSE_DATE.call(service_line['serviceDate'])
                  if service_date_begin.nil? || service_line_date < service_date_begin
                    service_date_begin = service_line_date
                  end
                  if service_date_end.nil? || service_date_end < service_line_date
                    service_date_end = service_line_date
                  end

                  adjudicated_procedure_code = service_line.dig('servicePaymentInformation', 'adjudicatedProcedureCode')
                  allowed_actual = service_line.dig('serviceSupplementalAmounts', 'allowedActual')
                  line_item_charge_amount = service_line.dig('servicePaymentInformation', 'lineItemChargeAmount')
                  line_item_provider_payment_amount = service_line.dig('servicePaymentInformation',
                                                                       'lineItemProviderPaymentAmount')

                  service_adjustments = []
                  service_line['serviceAdjustments']&.each do |service_adjustment|
                    adjustments = {}
                    # - 2 b/c group code & value, / 2 b/c come in pairs
                    num_adjustments = (service_adjustment.keys.size - 2) / 2
                    (1..num_adjustments).each do |index|
                      adjustment_reason = service_adjustment["adjustmentReasonCode#{index}"]
                      adjustment_amount = service_adjustment["adjustmentAmount#{index}"]
                      adjustments[adjustment_reason] = adjustment_amount
                    end

                    claim_adjustment_group_code = service_adjustment['claimAdjustmentGroupCode']

                    service_adjustments << Report835ServiceAdjustment.new(
                      adjustments: adjustments,
                      claim_adjustment_group_code: claim_adjustment_group_code
                    )
                  end

                  service_lines << Report835ServiceLine.new(
                    adjudicated_procedure_code: adjudicated_procedure_code,
                    allowed_actual: allowed_actual,
                    line_item_charge_amount: line_item_charge_amount,
                    line_item_provider_payment_amount: line_item_provider_payment_amount,
                    service_adjustments: service_adjustments
                  )
                end

                report_claims << Report835Claim.new(
                  patient_first_name: patient_first_name,
                  patient_last_name: patient_last_name,
                  payer_claim_control_number: payer_claim_control_number,
                  payer_identification: payer_identification,
                  payer_name: payer_name,
                  payment_method_code: payment_method_code,
                  report_creation_date: report_creation_date,
                  service_date_begin: service_date_begin,
                  service_date_end: service_date_end,
                  service_lines: service_lines,
                  service_provider_npi: service_provider_npi,
                  total_actual_provider_payment_amount: total_actual_provider_payment_amount,
                  total_charge_amount: total_charge_amount
                )
              end
            end
          end

          report_claims
        end
      end
    end
  end
end
