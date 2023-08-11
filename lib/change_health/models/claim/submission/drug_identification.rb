module ChangeHealth
  module Models
    module Claim
      class DrugIdentification < Model
        property :measurementUnitCode, from: :measurement_unit_code
        property :nationalDrugCode, from: :national_drug_code
        property :nationalDrugUnitCount, from: :national_drug_unit_count
        property :serviceIdQualifier, from: :service_id_qualifier
      end
    end
  end
end
