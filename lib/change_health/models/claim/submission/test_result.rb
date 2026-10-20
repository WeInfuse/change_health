# frozen_string_literal: true

module ChangeHealth
  module Models
    module Claim
      class TestResult < Model
        property :measurementQualifier, from: :measurement_qualifier
        property :measurementReferenceIdentificationCode, from: :measurement_reference_identification_code
        property :testResults, from: :test_results
      end
    end
  end
end
