module ChangeHealth
  module Models
    module Claim
      class Address < Model
        property :address1, required: false
        property :address2, required: false
        property :city, required: false
        property :postalCode, from: :postal_code, required: false
        property :state, required: false
      end
    end
  end
end
