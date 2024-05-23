module ChangeHealth
  module Models
    module Claim
      class OtherSubscriberInformation < Model
        property :benefitsAssignmentCertificationIndicator, from: :benefits_assignment_certification_indicator
        property :claimFilingIndicatorCode, from: :claim_filing_indicator_code
        property :claimLevelAdjustments, from: :claim_level_adjustments
        property :individualRelationshipCode, from: :individual_relationship_code
        property :otherPayerName, from: :other_payer_name
        property :otherSubscriberName, from: :other_subscriber_name
        property :payerPaidAmount, from: :payer_paid_amount
        property :paymentResponsibilityLevelCode, from: :payment_responsibility_level_code
        property :releaseOfInformationCode, from: :release_of_information_code
        property :remainingPatientLiability, from: :remaining_patient_liability
        property :nonCoveredChargeAmount, from: :non_covered_charge_amount
      end
    end
  end
end
