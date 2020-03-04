module ChangeHealth
  module Models
    DATE_FORMAT = '%Y%m%d'

    class Encounter < Hashie::Trash
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

      def to_h
        result = super.to_h

        [:beginningDateOfService, :dateOfService, :endDateOfService].each do |key|
          result[key] = result[key].strftime(ChangeHealth::Models::DATE_FORMAT) if result[key].respond_to?(:strftime)
        end

        result
      end

      def as_json(args = {})
        self.to_h
      end
    end
  end
end
