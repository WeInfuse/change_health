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

        def create_remark_code_adjustments(remark_codes_array)
          adjustment_array = remark_codes_array.map do |_key, value|
            {
              adjustmentReasonCode: value,
              adjustmentAmount: ""
            }
          end
          {
            adjustmentDetails: adjustment_array,
            adjustmentGroupCode: ""
          }
        end

        def create_adjustment_detail_array
          all_service_adjustments = self.service_adjustments
          adjustment_details = all_service_adjustments.map do |service_adjustments|
            create_group_adjustments(service_adjustments)
          end

          health_care_check_remark_codes = self[:health_care_check_remark_codes]
          health_care_check_remark_codes.each do |remark_codes|
            adjustment_details << create_remark_code_adjustments(remark_codes)
          end
          adjustment_details
        end
      end
    end
  end
end
