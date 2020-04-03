module ChangeHealth
  module Models
    class Subscriber < Model
      property :additionalIdentification, required: false
      property :address, required: false
      property :birthSequenceNumber, from: :birth_sequence_number, required: false
      property :caseNumber, from: :case_number, required: false
      property :dateOfBirth, from: :date_of_birth, required: false
      property :firstName, from: :first_name, required: false
      property :gender, required: false
      property :groupNumber, from: :group_number, required: false
      property :healthCareCodeInformation, from: :health_care_code_information, required: false
      property :idCard, from: :id_card, required: false
      property :idCardIssueDate, from: :id_card_issued_date, required: false
      property :lastName, from: :last_name, required: false
      property :medicaidRecipientIdentificationNumber, from: :medicaid_recipient_identification_number, required: false
      property :memberId, from: :member_id, required: false
      property :providerCode, from: :provider_code, required: false
      property :providerIdentifier, from: :provider_identification, required: false
      property :referenceIdentificationQualifier, from: :reference_identification_qualifier, required: false
      property :ssn, required: false

      def add_health_care_code_information(value)
        self[:healthCareCodeInformation] ||= []
        self[:healthCareCodeInformation] << value
      end
    end
  end
end
