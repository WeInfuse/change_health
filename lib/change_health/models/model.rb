# frozen_string_literal: true

module ChangeHealth
  module Models
    DATE_FORMAT = '%Y%m%d'
    DATE_HOUR_FORMAT = '%Y%m%d%H%M'
    HOUR_FORMAT = '%H%M'

    # Deprecated should use date_formatter instead
    DATE_FORMATTER = lambda { |date|
      time_formatter(date, DATE_FORMAT)
    }

    def self.date_formatter(date)
      time_formatter(date, DATE_FORMAT)
    end

    def self.date_hour_formatter(date_hour)
      time_formatter(date_hour, DATE_HOUR_FORMAT)
    end

    def self.hour_formatter(hour)
      time_formatter(hour, HOUR_FORMAT)
    end

    # rubocop:disable Lint/SuppressedException
    def self.time_formatter(time, format)
      begin
        time = Time.parse(time) if time.is_a?(String)
      rescue ArgumentError
      end

      time = time.strftime(format) if time.respond_to?(:strftime)

      time
    end
    # rubocop:enable Lint/SuppressedException

    # rubocop:disable Lint/SuppressedException
    PARSE_DATE = lambda { |d|
      begin
        d = Date.strptime(d.tr('-', ''), ChangeHealth::Models::DATE_FORMAT)
      rescue StandardError
      end

      d
    }
    # rubocop:enable Lint/SuppressedException

    # rubocop:disable Lint/SuppressedException
    POSTAL_CODE_FORMATTER = lambda { |postal_code|
      begin
        formatted_postal_code = postal_code&.to_s&.tr('-', '')
      rescue StandardError
      end
      formatted_postal_code || postal_code
    }
    # rubocop:enable Lint/SuppressedException

    CONTROL_NUMBER = -> { format('%09d', rand(1_000_000_000)) }

    class Model < Hashie::Trash
      def to_h
        self.class.hashify(self)
      end

      # rubocop:disable Style/MapToHash
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
      # rubocop:enable Style/MapToHash

      def self.format_value(key, value)
        return nil if value == ''

        downcased_key = key.to_s.downcase

        return ChangeHealth::Models.date_hour_formatter(value) if downcased_key.include?('dateandhour')

        return ChangeHealth::Models.hour_formatter(value) if downcased_key.include?('hour')

        return ChangeHealth::Models.date_formatter(value) if downcased_key.include?('date')

        return ChangeHealth::Models::POSTAL_CODE_FORMATTER.call(value) if downcased_key.include?('postalcode')

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
