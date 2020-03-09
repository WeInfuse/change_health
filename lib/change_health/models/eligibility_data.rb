module ChangeHealth
  module Models
    class EligibilityData
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

      def active?(service_code: '30')
        return '1' == plan_status(service_code: service_code).dig('statusCode')
      end

      %w(planStatus benefitsInformation controlNumber).each do |v|
        define_method(v) do
          @raw.dig(v)
        end
      end

      def plan_status(service_code: )
        self.planStatus&.find {|plan| plan.dig('serviceTypeCodes').include?(service_code) } || {}
      end

      def benefits
        ChangeHealth::Models::EligibilityBenefits.new(self.benefitsInformation || [])
      end

      alias_method :control_number, :controlNumber
      alias_method :benefits_information, :benefitsInformation
      alias_method :plan_statuses, :planStatus
    end
  end
end
