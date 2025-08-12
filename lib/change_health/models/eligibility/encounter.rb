# frozen_string_literal: true

module ChangeHealth
  module Models
    module Eligibility
      class Encounter < Model
        property :beginningDateOfService, from: :beginning_date_of_service, required: false
        property :dateOfService, from: :date_of_service, required: false
        property :dateRange, from: :date_range, required: false, default: false
        property :endDateOfService, from: :end_date_of_service, required: false
        property :serviceTypeCodes, from: :service_type_codes, required: false

        # rubocop:disable Naming/MethodName
        alias dateRange? dateRange
        # rubocop:enable Naming/MethodName
        alias date_range? dateRange
        alias service_type_codes serviceTypeCodes

        def add_service_type_code(code)
          self[:serviceTypeCodes] ||= []
          self[:serviceTypeCodes] << code
        end
      end
    end
  end
end
