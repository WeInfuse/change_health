module ChangeHealth
  module Response
    module Claim
      # Methods only return meaningful data for json reports
      class Report277Data < ChangeHealth::Response::Claim::ReportData
        def transactions
          @raw['transactions']
        end

        # Only one payer per report
        def payer_name
          transactions&.first&.dig('payers')&.first&.dig('organizationName')
        end

        def report_creation_date
          ChangeHealth::Models::PARSE_DATE.call(transactions&.first&.dig('transactionSetCreationDate'))
        end

        def claims
          report_claims = []

          transactions&.each do |transaction|
            report_creation_date = ChangeHealth::Models::PARSE_DATE.call(transaction['transactionSetCreationDate'])
            transaction['payers']&.each do |payer|
              payer_identification = payer['payerIdentification']
              payer_name = payer['organizationName']
              payer['claimStatusTransactions']&.each do |claim_status_txn|
                claim_status_txn['claimStatusDetails']&.each do |claim_status_detail|
                  service_provider_npi = claim_status_detail.dig('serviceProvider', 'npi')
                  claim_status_detail['patientClaimStatusDetails']&.each do |patient_claim_status_detail|
                    patient_first_name = patient_claim_status_detail.dig('subscriber', 'firstName')
                    patient_last_name = patient_claim_status_detail.dig('subscriber', 'lastName')
                    patient_claim_status_detail['claims']&.each do |claim|
                      procedure_codes = []
                      claim['serviceLines']&.each do |service_line|
                        procedure_codes << service_line.dig('service', 'procedureCode')
                      end
                      claim_status = claim['claimStatus']
                      next if claim_status.nil?

                      service_date_begin = ChangeHealth::Models::PARSE_DATE.call(claim_status['claimServiceBeginDate'] || claim_status['claimServiceDate'])
                      service_date_end = ChangeHealth::Models::PARSE_DATE.call(claim_status['claimServiceEndDate'] || claim_status['claimServiceDate'])

                      info_claim_statuses = []
                      claim_status['informationClaimStatuses']&.each do |info_claim_status|
                        status_information_effective_date = ChangeHealth::Models::PARSE_DATE.call(info_claim_status['statusInformationEffectiveDate'])
                        total_charge_amount = info_claim_status['totalClaimChargeAmount']

                        status_category_codes = []
                        info_claim_status['informationStatuses']&.each do |info_status|
                          status_category_codes << info_status['healthCareClaimStatusCategoryCode']
                        end

                        info_claim_statuses << Report277InfoClaimStatus.new(
                          status_category_codes: status_category_codes,
                          total_charge_amount: total_charge_amount,
                          status_information_effective_date: status_information_effective_date
                        )
                      end
                      report_claims << Report277Claim.new(
                        info_claim_statuses: info_claim_statuses,
                        patient_first_name: patient_first_name,
                        patient_last_name: patient_last_name,
                        payer_identification: payer_identification,
                        payer_name: payer_name,
                        procedure_codes: procedure_codes,
                        report_creation_date: report_creation_date,
                        service_date_begin: service_date_begin,
                        service_date_end: service_date_end,
                        service_provider_npi: service_provider_npi
                      )
                    end
                  end
                end
              end
            end
          end

          report_claims
        end
      end
    end
  end
end
