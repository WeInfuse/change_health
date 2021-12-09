module ChangeHealth
  module Response
    class ResponseData
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
        errors.is_a?(Array) && false == errors.empty?
      end

      def errors
        errors = @raw.dig('errors') || []

        errors.flatten.map { |error| ChangeHealth::Response::Error.new(error) }
      end

      def recommend_retry?
        return false unless errors?

        return true if errors.any?(&:represents_down?)

        error_codes = errors.select(&:code?)

        return false if error_codes.empty?

        error_codes.all?(&:retryable?)
      end
    end
  end
end
