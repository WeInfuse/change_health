module ChangeHealth
  module Models
    DATE_FORMAT = '%Y%m%d'
    DATE_FORMATTER = lambda { |d|
      begin
        d = Date.parse(d) if d.is_a?(String)
      rescue ArgumentError
      end

      d = d.strftime(ChangeHealth::Models::DATE_FORMAT) if d.respond_to?(:strftime)

      d
    }

    PARSE_DATE = lambda { |d|
      begin
        d = Date.strptime(d, ChangeHealth::Models::DATE_FORMAT)
      rescue StandardError
      end

      d
    }

    POSTAL_CODE_FORMATTER = lambda { |postal_code|
      begin
        formatted_postal_code = postal_code&.to_s&.tr('-', '')
      rescue StandardError
      end
      formatted_postal_code || postal_code
    }

    CONTROL_NUMBER = -> { '%09d' % rand(1_000_000_000) }

    class Model < Hashie::Trash
      def to_h
        self.class.hashify(self)
      end

      def self.hashify(model)
        model.map do |key, value|
          formatted_value = case value
                            when Hash
                              hashify(model[key])
                            when Array
                              value.map do |element|
                                if element.is_a?(Hash)
                                  hashify(element)
                                else # if it's an array of arrays, can't handle it
                                  format_value(key, element)
                                end
                              end
                            else
                              format_value(key, value)
                            end
          [key, formatted_value]
        end.to_h
      end

      def self.format_value(key, value)
        return nil if value == ''

        return ChangeHealth::Models::DATE_FORMATTER.call(value) if key.to_s.downcase.include?('date')
        return ChangeHealth::Models::POSTAL_CODE_FORMATTER.call(value) if key.to_s.downcase.include?('postalcode')

        value
      end

      def as_json(_args = {})
        to_h
      end

      def to_json(*_args)
        to_h.to_json
      end
    end
  end
end
