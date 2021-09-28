module ChangeHealth
  module Models
    module Claim
      class Provider < Hashie::Trash
        property :address, required: false
        property :employerId, from: :employer_id, required: false # or ssn
        property :firstName, from: :first_name, required: false
        property :lastName, from: :last_name, required: false
        property :npi, required: false
        property :providerType, from: :provider_type, required: false
        property :ssn, required: false # or employer id
      end
    end
  end
end
