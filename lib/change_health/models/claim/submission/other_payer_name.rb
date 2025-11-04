# frozen_string_literal: true

module ChangeHealth
  module Models
    module Claim
      class OtherPayerName < Model
        property :otherPayerClaimControlNumber, from: :other_payer_claim_control_number
        property :otherPayerIdentifier, from: :other_payer_identifier
        property :otherPayerIdentifierTypeCode, from: :other_payer_identifier_type_code
        property :otherPayerOrganizationName, from: :other_payer_organization_name
        property :otherPayerSecondaryIdentifier, from: :other_payer_secondary_identifier

        def add_other_payer_secondary_identifier(secondary_identifier)
          self[:otherPayerSecondaryIdentifier] ||= []
          self[:otherPayerSecondaryIdentifier] << secondary_identifier
        end
      end
    end
  end
end
