# frozen_string_literal: true

module ChangeHealth
  module Models
    module Claim
      class Submitter < Model
        property :contactInformation, from: :contact_information
        property :organizationName, from: :organization_name
      end
    end
  end
end
