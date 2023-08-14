module ChangeHealth
  module Models
    module Claim
      class OtherSubscriberName < Model
        property :otherInsuredFirstName, from: :other_insured_first_nsame
        property :otherInsuredIdentifier, from: :other_insured_identifier
        property :otherInsuredIdentifierTypeCode, from: :other_insured_identifier_type_code
        property :otherInsuredLastName, from: :other_insured_last_name
        property :otherInsuredQualifier, from: :other_insured_qualifier
      end
    end
  end
end
