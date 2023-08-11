module ChangeHealth
  module Models
    module Claim
      class Provider < Model
        property :address
        property :contactInformation, from: :contact_information
        property :employerId, from: :employer_id # or ssn
        property :firstName, from: :first_name
        property :lastName, from: :last_name
        property :npi
        property :organizationName, from: :organization_name
        property :providerType, from: :provider_type
        property :ssn # or employer id
        property :taxonomyCode, from: :taxonomy_code
      end
    end
  end
end
