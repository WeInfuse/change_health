module ChangeHealth
  module Models
    module Claim
      class claimLevelAdjustments < Model
        property :adjustmentGroupCode, from: :adjustment_group_code
        property :adjustmentDetails, from: :adjustment_details
      end
    end
  end
end
