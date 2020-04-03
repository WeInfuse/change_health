module ChangeHealth
  module Models
    class Encounter < Model
      property :beginningDateOfService, from: :beginning_date_of_service, required: false
      property :dateOfService, from: :date_of_service, required: false
      property :dateRange, from: :date_range, required: false, default: false
      property :endDateOfService, from: :end_date_of_service, required: false
      property :serviceTypeCodes, from: :service_type_codes, required: false

      alias_method :dateRange?, :dateRange
      alias_method :date_range?, :dateRange
      alias_method :service_type_codes, :serviceTypeCodes

      def add_service_type_code(code)
        self[:serviceTypeCodes] ||= []
        self[:serviceTypeCodes] << code
      end
    end
  end
end
