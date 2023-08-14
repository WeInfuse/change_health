module ChangeHealth
  module Models
    module Claim
      class ServiceFacilityLocation < Model
        property :address
        property :organizationName, from: :organization_name
        property :npi
        property :phoneNumber, from: :phone_number
      end
    end
  end
end
