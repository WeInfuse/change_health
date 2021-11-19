module ChangeHealth
  module Response
    module Claim
      # Methods only return meaningful data for json reports
      class Report277Data < ChangeHealth::Response::Claim::ReportData
        def transactions
          @raw['transactions']
        end

        # Only one payer per report
        def payer_org_name
          transactions&.first&.dig('payers')&.first&.dig('organizationName')
        end

        def claims
          report_claims = []

          transactions&.each do |transaction|
            transaction_set_creation_date = ChangeHealth::Models::PARSE_DATE.call(transaction['transactionSetCreationDate'])
            transaction['payers']&.each do |payer|
              payer_org_name = payer['organizationName']
              payer['claimStatusTransactions']&.each do |claim_status_txn|
                claim_status_txn['claimStatusDetails']&.each do |claim_status_detail|
                  service_provider_npi = claim_status_detail.dig('serviceProvider', 'npi')
                  claim_status_detail['patientClaimStatusDetails']&.each do |patient_claim_status_detail|
                    subscriber_first_name = patient_claim_status_detail.dig('subscriber', 'firstName')
                    subscriber_last_name = patient_claim_status_detail.dig('subscriber', 'lastName')
                    patient_claim_status_detail['claims']&.each do |claim|
                      procedure_codes = []
                      claim['serviceLines']&.each do |service_line|
                        procedure_codes << service_line.dig('service', 'procedureCode')
                      end
                      claim_status = claim['claimStatus']
                      next if claim_status.nil?

                      service_begin_date = ChangeHealth::Models::PARSE_DATE.call(claim_status['claimServiceBeginDate'] || claim_status['claimServiceDate'])
                      service_end_date = ChangeHealth::Models::PARSE_DATE.call(claim_status['claimServiceEndDate'] || claim_status['claimServiceDate'])

                      info_claim_statuses = []
                      claim_status['informationClaimStatuses']&.each do |info_claim_status|
                        status_information_effective_date = ChangeHealth::Models::PARSE_DATE.call(info_claim_status['statusInformationEffectiveDate'])
                        total_charge_amount = info_claim_status['totalClaimChargeAmount']

                        status_category_codes = []
                        info_claim_status['informationStatuses']&.each do |info_status|
                          status_category_codes << info_status['healthCareClaimStatusCategoryCode']
                        end

                        info_claim_statuses << ReportInfoClaimStatus.new(
                          status_category_codes: status_category_codes,
                          total_charge_amount: total_charge_amount,
                          status_information_effective_date: status_information_effective_date
                        )
                      end
                      report_claims << ReportClaim.new(
                        transaction_set_creation_date: transaction_set_creation_date,
                        payer_org_name: payer_org_name,
                        service_provider_npi: service_provider_npi,
                        subscriber_first_name: subscriber_first_name,
                        subscriber_last_name: subscriber_last_name,
                        procedure_codes: procedure_codes,
                        service_begin_date: service_begin_date,
                        service_end_date: service_end_date,
                        info_claim_statuses: info_claim_statuses
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
