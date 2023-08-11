module ChangeHealth
  module Models
    module Claim
      class Address < Model
        property :address1
        property :address2
        property :city
        property :postalCode, from: :postal_code
        property :state
      end
    end
  end
end
