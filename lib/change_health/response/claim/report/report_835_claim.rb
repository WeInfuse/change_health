module ChangeHealth
  module Response
    module Claim
      class Report835Claim < ReportClaim
        property :raw_claim_adjustments, required: false
        property :claim_adjustments, required: false
        property :claim_payment_amount, required: false
        property :claim_payment_remark_codes, required: false
        property :claim_status_code, required: false
        property :patient_control_number, required: false
        property :payer_claim_control_number, required: false
        property :service_lines, required: false
        property :raw_service_lines, required: false
        property :total_charge_amount, required: false
        property :payer_identification, required: false
        property :patient_responsibility_amount, required: false
        property :class_of_contract_code, required: false
        property :group_or_policy_number, required: false
        property :claim_supplemental_information, required: false
        property :payee_npi, required: false
        property :filing_indicator_code, required: false
        property :payee_name, required: false
        property :payee_tin, required: false
        property :rendering_provider_npi, required: false
        property :payer_state, required: false
        property :payment_method_code, required: false
        property :payer_name, required: false
        property :claim_received_date, required: false
        property :unit_of_service_paid_count, required: false
        property :claim_frequency_code, required: false
        property :provider_control_number, required: false

        def procedure_codes
          service_lines&.map(&:adjudicated_procedure_code)
        end
      end
    end
  end
end
