module ChangeHealth
  module Models
    module Claim
      class ServiceLine < Model

        property :serviceDate, from: :service_date, required: false
        property :professionalService, from: :professional_service, required: false

      end
    end
  end
end
