module ChangeHealth
  module Models
    module Claim
      class ServiceLine < Model
        property :drugIdentification, from: :drug_identification, required: false
        property :serviceDate, from: :service_date, required: false
        property :professionalService, from: :professional_service, required: false
        property :renderingProvider, from: :rendering_provider, required: false
      end
    end
  end
end
