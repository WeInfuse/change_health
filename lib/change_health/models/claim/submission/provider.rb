module ChangeHealth
  module Models
    module Claim
      class Provider < Hashie::Trash
        property :address, required: false
        property :contactInformation, from: :contact_information, required: false
        property :employerId, from: :employer_id, required: false # or ssn
        property :firstName, from: :first_name, required: false
        property :lastName, from: :last_name, required: false
        property :organizationName, from: :organization_name, required: false
        property :npi, required: false
        property :providerType, from: :provider_type, required: false
        property :taxonomyCode, from: :taxonomy_code, required: false
        property :ssn, required: false # or employer id
      end
    end
  end
end
