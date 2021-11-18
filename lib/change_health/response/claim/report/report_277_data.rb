module ChangeHealth
  module Response
    module Claim
      # Methods only return meaningful data for json reports
      class Report277Data < ChangeHealth::Response::Claim::ReportData
        def transactions
          @raw.dig('transactions')
        end

        # Only one payer per report
        def payer_org_name
          transactions&.first&.dig('payers')&.first&.dig('organizationName')
        end

        def claims
          report_claims = []

          transactions&.each do |transaction|
            transaction_set_creation_date = ChangeHealth::Models::PARSE_DATE.call(transaction.dig('transactionSetCreationDate'))
            transaction.dig('payers')&.each do |payer|
              payer_org_name = payer.dig('organizationName')
              payer.dig('claimStatusTransactions')&.each do |claim_status_txn|
                claim_status_txn.dig('claimStatusDetails')&.each do |claim_status_detail|
                  service_provider_npi = claim_status_detail.dig('serviceProvider')&.dig('npi')
                  claim_status_detail.dig('patientClaimStatusDetails')&.each do |patient_claim_status_detail|
                    subscriber_first_name = patient_claim_status_detail.dig('subscriber')&.dig('firstName')
                    subscriber_last_name = patient_claim_status_detail.dig('subscriber')&.dig('lastName')
                    patient_claim_status_detail.dig('claims')&.each do |claim|
                      procedure_codes = []
                      claim.dig('serviceLines')&.each do |service_line|
                        procedure_codes << service_line.dig('service').dig('procedureCode')
                      end
                      claim_status = claim.dig('claimStatus')
                      service_begin_date = ChangeHealth::Models::PARSE_DATE.call(claim_status&.dig('claimServiceBeginDate') || claim_status&.dig('claimServiceDate'))
                      service_end_date = ChangeHealth::Models::PARSE_DATE.call(claim_status&.dig('claimServiceEndDate') || claim_status&.dig('claimServiceDate'))

                      info_claim_statuses = []
                      claim_status&.dig('informationClaimStatuses')&.each do |info_claim_status|
                        status_information_effective_date = ChangeHealth::Models::PARSE_DATE.call(info_claim_status.dig('statusInformationEffectiveDate'))
                        total_charge_amount = info_claim_status.dig('totalClaimChargeAmount')

                        status_category_codes = []
                        info_claim_status.dig('informationStatuses')&.each do |info_status|
                          status_category_codes << info_status.dig('healthCareClaimStatusCategoryCode')
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
