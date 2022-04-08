module ChangeHealth
  module Response
    module Claim
      class Report835Claim < ReportClaim
        property :check_issue_or_eft_effective_date, required: false
        property :check_or_eft_trace_number, required: false
        property :claim_payment_remark_codes, required: false
        property :patient_control_number, required: false
        property :payer_claim_control_number, required: false
        property :payer_identifier, required: false
        property :payment_method_code, required: false
        property :service_lines, required: false
        property :total_actual_provider_payment_amount, required: false
        property :total_charge_amount, required: false

        def procedure_codes
          service_lines&.map(&:adjudicated_procedure_code)
        end
      end
    end
  end
end
