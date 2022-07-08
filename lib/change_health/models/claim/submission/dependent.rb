module ChangeHealth
  module Models
    module Claim
      class Dependent < Model
        property :address, required: false
        property :dateOfBirth, from: :date_of_birth, required: false
        property :firstName, from: :first_name, required: false
        property :gender, required: false
        property :lastName, from: :last_name, required: false
        property :memberId, from: :member_id, required: false
        property :relationshipToSubscriberCode, from: :relationship_to_subscriber_code, required: false
      end
    end
  end
end
