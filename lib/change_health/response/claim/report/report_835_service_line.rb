module ChangeHealth
  module Response
    module Claim
      class Report835ServiceLine < Hashie::Trash
        property :adjudicated_procedure_code, required: false
        property :allowed_actual, required: false
        property :health_care_check_remark_codes, required: false
        property :line_item_charge_amount, required: false
        property :line_item_provider_payment_amount, required: false
        property :service_adjustments, required: false
        property :provider_control_number, required: false

        def create_group_adjustments(service_adjustments)
          adjustment_array = service_adjustments[:adjustments].map do |key, value|
            {
              adjustmentReasonCode: key,
              adjustmentAmount: value
            }
          end
          {
            adjustmentDetails: adjustment_array,
            adjustmentGroupCode: service_adjustments[:claim_adjustment_group_code]
          }
        end

        def create_adjustment_detail_array
          service_adjustments&.map do |service_adjustments|
            create_group_adjustments(service_adjustments)
          end || []
        end
      end
    end
  end
end
