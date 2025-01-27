module ChangeHealth
  module Response
    module Claim
      class Report835ServiceLine < Hashie::Trash
        property :adjudicated_procedure_code
        property :allowed_actual
        property :health_care_check_remark_codes
        property :line_item_charge_amount
        property :line_item_provider_payment_amount
        property :service_adjustments
        property :service_date
        property :service_date_begin
        property :service_date_end

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
