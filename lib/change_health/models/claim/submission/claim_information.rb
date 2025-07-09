# frozen_string_literal: true

module ChangeHealth
  module Models
    module Claim
      class ClaimInformation < Model
        property :admittingDiagnosis, from: :admitting_diagnosis
        property :benefitsAssignmentCertificationIndicator, from: :benefits_assignment_certification_indicator
        property :claimChargeAmount, from: :claim_charge_amount
        property :claimCodeInformation, from: :claim_code_information
        property :claimDateInformation, from: :claim_date_information
        property :claimFilingCode, from: :claim_filing_code
        property :claimFrequencyCode, from: :claim_frequency_code
        property :claimNote, from: :claim_note
        property :claimNotes, from: :claim_notes
        property :claimSupplementalInformation, from: :claim_supplemental_information
        property :healthCareCodeInformation, from: :health_care_code_information
        property :otherDiagnosisInformationList, from: :other_diagnosis_information_list
        property :otherSubscriberInformation, from: :other_subscriber_information
        property :patientControlNumber, from: :patient_control_number
        property :placeOfServiceCode, from: :place_of_service_code
        property :planParticipationCode, from: :plan_participation_code
        property :principalDiagnosis, from: :principal_diagnosis
        property :releaseInformationCode, from: :release_information_code
        property :serviceFacilityLocation, from: :service_facility_location
        property :serviceLines, from: :service_lines
        property :signatureIndicator, from: :signature_indicator

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
