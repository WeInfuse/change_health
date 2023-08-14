module ChangeHealth
  module Models
    module Claim
      class ServiceLine < Model
        property :assignedNumber, from: :assigned_number
        property :drugIdentification, from: :drug_identification
        property :institutionalService, from: :institutional_service
        property :lineAdjudicationInformation, from: :line_adjudication_information
        property :professionalService, from: :professional_service
        property :renderingProvider, from: :rendering_provider
        property :serviceDate, from: :service_date
      end
    end
  end
end
