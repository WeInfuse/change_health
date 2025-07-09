# frozen_string_literal: true

module ChangeHealth
  module Models
    module Claim
      # Can be used for
      # - admittingDiagnosis
      # - healthCareCodeInformation items
      # - otherDiagnosisInformationList items
      # - principalDiagnosis
      class Diagnosis < Model
        property :admittingDiagnosisCode, from: :admitting_diagnosis_code
        property :diagnosisCode, from: :diagnosis_code
        property :diagnosisTypeCode, from: :diagnosis_type_code
        property :otherDiagnosisCode, from: :other_diagnosis_code
        property :principalDiagnosisCode, from: :principal_diagnosis_code
        property :qualifierCode, from: :qualifier_code
      end
    end
  end
end
