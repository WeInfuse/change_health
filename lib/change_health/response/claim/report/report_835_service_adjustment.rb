module ChangeHealth
  module Response
    module Claim
      class Report835ServiceAdjustment < Hashie::Trash
        property :adjustments, required: false
        property :claim_adjustment_group_code, required: false
        property :claim_adjustment_group_code_value, required: false

        def add_adjustment(adjustment)
          self[:adjustments] ||= []
          self[:adjustments] << adjustment
        end
      end
    end
  end
end
