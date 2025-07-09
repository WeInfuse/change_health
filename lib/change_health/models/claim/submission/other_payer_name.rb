# frozen_string_literal: true

module ChangeHealth
  module Models
    module Claim
      class OtherPayerName < Model
        property :otherPayerIdentifier, from: :other_payer_identifier
        property :otherPayerIdentifierTypeCode, from: :other_payer_identifier_type_code
        property :otherPayerOrganizationName, from: :other_payer_organization_name
      end
    end
  end
end
