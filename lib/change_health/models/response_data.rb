module ChangeHealth
  module Models
    module ResponseData
      attr_reader :response, :raw

      def initialize(data: nil, response: nil)
        @response = response
        @raw      = data

        begin
          @raw ||= response&.parsed_response
        rescue JSON::ParserError
        end

        @raw ||= {}
      end

      def errors?
        self.errors.is_a?(Array) && false == self.errors.empty?
      end

      def errors
        errors = @raw.dig('errors') || []

        errors.flatten.map {|error| ChangeHealth::Models::Error.new(error) }
      end

      def recommend_retry?
        return false unless errors?

        return true if errors.any?(&:represents_down?)

        error_codes = errors.select(&:code?)

        return false if error_codes.empty?

        return error_codes.all?(&:retryable?)
      end
    end
  end
end
