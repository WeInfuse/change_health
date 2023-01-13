module ChangeHealth
  module Response
    module Claim
      class Report835Claim < ReportClaim
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

        def procedure_codes
          service_lines&.map(&:adjudicated_procedure_code)
        end
      end
    end
  end
end
