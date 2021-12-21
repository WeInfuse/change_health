module ChangeHealth
  module Models
    module Claim
      class DrugIdentification < Model
        property :measurementUnitCode, from: :measurement_unit_code, required: false
        property :nationalDrugCode, from: :national_drug_code, required: false
        property :nationalDrugUnitCount, from: :national_drug_unit_count, required: false
        property :serviceIdQualifier, from: :service_id_qualifier, required: false
      end
    end
  end
end
