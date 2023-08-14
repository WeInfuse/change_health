module ChangeHealth
  module Models
    module Claim
      class Subscriber < Model
        property :address
        property :dateOfBirth, from: :date_of_birth
        property :firstName, from: :first_name
        property :gender
        property :groupNumber, from: :group_number
        property :insuranceTypeCode, from: :insurance_type_code
        property :lastName, from: :last_name
        property :memberId, from: :member_id
        property :paymentResponsibilityLevelCode, from: :payment_responsibility_level_code
      end
    end
  end
end
