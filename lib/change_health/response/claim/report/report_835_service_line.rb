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
      end
    end
  end
end
