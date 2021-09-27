module ChangeHealth
  module Models
    module Claim
      class Submitter < Hashie::Trash
        property :organizationName, from: :organization_name, required: false
        # contact information has a name & phone number inside
        property :contactInformation, from: :contact_information, required: false
      end
    end
  end
end
