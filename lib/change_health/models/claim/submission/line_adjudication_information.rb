# frozen_string_literal: true

module ChangeHealth
  module Models
    module Claim
      class LineAdjudicationInformation < Model
        property :adjudicationOrPaymentDate, from: :adjudication_or_payment_date
        property :claimAdjustmentInformation, from: :claim_adjustment_information
        property :otherPayerPrimaryIdentifier, from: :other_payer_primary_identifier
        property :paidServiceUnitCount, from: :paid_service_unit_count
        property :procedureCode, from: :procedure_code
        property :procedureModifier, from: :procedure_modifier
        property :remainingPatientLiability, from: :remaining_patient_liability
        property :serviceIdQualifier, from: :service_id_qualifier
        property :serviceLinePaidAmount, from: :service_line_paid_amount
      end
    end
  end
end
