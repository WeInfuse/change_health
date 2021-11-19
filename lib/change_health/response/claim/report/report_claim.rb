module ChangeHealth
  module Response
    module Claim
      class ReportClaim < Hashie::Trash
        property :transaction_set_creation_date, required: false
        property :payer_org_name, required: false
        property :service_provider_npi, required: false
        property :subscriber_first_name, required: false
        property :subscriber_last_name, required: false
        property :procedure_codes, required: false
        property :service_begin_date, required: false
        property :service_end_date, required: false
        property :info_claim_statuses, required: false

        def add_procedure_code(procedure_code)
          self[:procedure_codes] ||= []
          self[:procedure_codes] << procedure_code
        end

        def add_info_claim_status(info_claim_status)
          self[:info_claim_statuses] ||= []
          self[:info_claim_statuses] << info_claim_status
        end

        def latest_status_category_codes
          latest_info_claim_status&.status_category_codes
        end

        def latest_total_charge_amount
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
