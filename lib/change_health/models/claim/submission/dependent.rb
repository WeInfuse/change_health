module ChangeHealth
  module Models
    module Claim
      class Dependent < Model
        property :address
        property :dateOfBirth, from: :date_of_birth
        property :firstName, from: :first_name
        property :gender
        property :lastName, from: :last_name
        property :memberId, from: :member_id
        property :relationshipToSubscriberCode, from: :relationship_to_subscriber_code
      end
    end
  end
end
