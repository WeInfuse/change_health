module ChangeHealth
  module Models
    module Claim
      class ClaimInformation < Hashie::Trash

        property :benefitsAssignmentCertificationIndicator, from: :benefits_assignment_certification_indicator, required: false
        property :claimChargeAmount, from: :claim_charge_amount, required: false
        property :claimFilingCode, from: :claim_filing_code, required: false
        property :claimFrequencyCode, from: :claim_frequency_code, required: false
        property :healthCareCodeInformation, from: :health_care_code_information, required: false
        property :patientControlNumber, from: :patient_control_number, required: false
        property :placeOfServiceCode, from: :place_of_service_code, required: false
        property :planParticipationCode, from: :plan_participation_code, required: false
        property :releaseInformationCode, from: :release_information_code, required: false
        property :serviceLines, from: :service_lines, required: false
        property :signatureIndicator, from: :signature_indicator, required: false

        def add_service_line(service_line)
          self[:serviceLines] ||= []
          self[:serviceLines] << service_line
        end

        def add_health_care_code_information(health_care_code_information)
          self[:healthCareCodeInformation] ||= []
          self[:healthCareCodeInformation] << health_care_code_information
        end
      end
    end
  end
end
