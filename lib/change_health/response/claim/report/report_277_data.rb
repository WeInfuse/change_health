# frozen_string_literal: true

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
          payers = transactions&.first&.dig('payers')

          payers&.first&.dig('organizationName')
        end

        def report_creation_date
          ChangeHealth::Models::PARSE_DATE.call(transactions&.first&.dig('transactionSetCreationDate'))
        end

        # rubocop:disable Metrics/AbcSize
        # rubocop:disable Metrics/BlockLength
        # rubocop:disable Metrics/MethodLength
        # rubocop:disable Metrics/PerceivedComplexity
        # rubocop:disable Metrics/CyclomaticComplexity
        def claims
          report_claims = []

          transactions&.each do |transaction|
            id = transaction['id']
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
                    patient_member_id = patient_claim_status_detail.dig('subscriber', 'memberId')

                    patient_claim_status_detail['claims']&.each do |claim|
                      report_claim_args = parse_patient_claim(claim)

                      next if report_claim_args.nil?

                      report_claims << Report277Claim.new(
                        id: id,
                        patient_first_name: patient_first_name,
                        patient_last_name: patient_last_name,
                        patient_member_id: patient_member_id,
                        payer_identification: payer_identification,
                        payer_name: payer_name,
                        report_creation_date: report_creation_date,
                        report_name: report_name,
                        service_provider_npi: service_provider_npi,
                        **report_claim_args
                      )
                    end
                  end
                end
              end
            end
          end

          report_claims
        end
        # rubocop:enable Metrics/AbcSize
        # rubocop:enable Metrics/BlockLength
        # rubocop:enable Metrics/MethodLength
        # rubocop:enable Metrics/PerceivedComplexity
        # rubocop:enable Metrics/CyclomaticComplexity

        # rubocop:disable Metrics/AbcSize
        # rubocop:disable Metrics/MethodLength
        # rubocop:disable Metrics/PerceivedComplexity
        # rubocop:disable Metrics/CyclomaticComplexity
        def parse_patient_claim(claim)
          procedure_codes = []
          claim['serviceLines']&.each do |service_line|
            procedure_codes << service_line.dig('service', 'procedureCode')
          end
          claim_status = claim['claimStatus']
          return if claim_status.nil?

          clearinghouse_trace_number = claim_status['clearinghouseTraceNumber']
          patient_account_number = claim_status['patientAccountNumber']
          referenced_transaction_trace_number = claim_status['referencedTransactionTraceNumber']
          trading_partner_claim_number = claim_status['tradingPartnerClaimNumber']

          service_date_begin = ChangeHealth::Models::PARSE_DATE.call(
            presence(claim_status['claimServiceBeginDate']) || presence(claim_status['claimServiceDate'])
          )
          service_date_end = ChangeHealth::Models::PARSE_DATE.call(
            presence(claim_status['claimServiceEndDate']) || presence(claim_status['claimServiceDate'])
          )

          info_claim_statuses = []
          claim_status['informationClaimStatuses']&.each do |info_claim_status|
            message = info_claim_status['message']
            status_information_effective_date = ChangeHealth::Models::PARSE_DATE.call(info_claim_status['statusInformationEffectiveDate'])
            total_charge_amount = info_claim_status['totalClaimChargeAmount']

            info_statuses = []
            info_claim_status['informationStatuses']&.each do |info_status|
              info_statuses << Report277InfoStatus.new(
                status_category_code: info_status['healthCareClaimStatusCategoryCode'],
                status_category_code_value: info_status['healthCareClaimStatusCategoryCodeValue'],
                status_code: info_status['statusCode'],
                status_code_value: info_status['statusCodeValue']
              )
            end

            info_claim_statuses << Report277InfoClaimStatus.new(
              message: message,
              info_statuses: info_statuses,
              total_charge_amount: total_charge_amount,
              status_information_effective_date: status_information_effective_date
            )
          end

          {
            clearinghouse_trace_number: clearinghouse_trace_number,
            info_claim_statuses: info_claim_statuses,
            patient_account_number: patient_account_number,
            procedure_codes: procedure_codes,
            referenced_transaction_trace_number: referenced_transaction_trace_number,
            service_date_begin: service_date_begin,
            service_date_end: service_date_end,
            trading_partner_claim_number: trading_partner_claim_number
          }
        end
        # rubocop:enable Metrics/AbcSize
        # rubocop:enable Metrics/MethodLength
        # rubocop:enable Metrics/PerceivedComplexity
        # rubocop:enable Metrics/CyclomaticComplexity
      end
    end
  end
end
