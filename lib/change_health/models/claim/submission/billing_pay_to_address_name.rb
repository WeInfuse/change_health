module ChangeHealth
  module Models
    module Claim
      class BillingPayToAddressName < Model
        property :address
        property :entityTypeQualifier, from: :entity_type_qualifier
      end
    end
  end
end
