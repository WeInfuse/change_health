module ChangeHealth
  module Models
    module Claim
      class ClaimCodeInformation < Model
        property :admissionSourceCode, from: :admission_source_code
        property :admissionTypeCode, from: :admission_type_code
        property :patientStatusCode, from: :patient_status_code
      end
    end
  end
end
