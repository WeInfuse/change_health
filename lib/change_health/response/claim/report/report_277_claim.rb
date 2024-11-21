module ChangeHealth
  module Response
    module Claim
      class Report277Claim < ReportClaim
        property :clearinghouse_trace_number, required: false
        property :info_claim_statuses, required: false
        property :patient_account_number, required: false
        property :procedure_codes, required: false
        property :referenced_transaction_trace_number, required: false
        property :trading_partner_claim_number, required: false

        def add_info_claim_status(info_claim_status)
          self[:info_claim_statuses] ||= []
          self[:info_claim_statuses] << info_claim_status
        end

        def add_procedure_code(procedure_code)
          self[:procedure_codes] ||= []
          self[:procedure_codes] << procedure_code
        end

        def latest_info_statuses
          latest_info_claim_status&.info_statuses
        end

        def latest_status_category_codes
          latest_info_statuses&.map(&:status_category_code)
        end

        def total_charge_amount
          latest_info_claim_status&.total_charge_amount
        end

        def latest_status_info_effective_date
          latest_info_claim_status&.status_information_effective_date
        end

        def latest_info_claim_status
          info_claim_statuses&.select do |info|
            !info.status_information_effective_date.nil? &&
              info.status_information_effective_date.is_a?(Date) &&
              info.status_information_effective_date <= Date.today
          end&.max_by(&:status_information_effective_date)
        end
      end
    end
  end
end
