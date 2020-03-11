module ChangeHealth
  module Models
    class EligibilityData
      attr_reader :response, :raw

      PARSE_DATE = ->(d) {
        begin
          d = Date.strptime(d, ChangeHealth::Models::DATE_FORMAT)
        rescue
        end

        d
      }

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

      %w(planStatus benefitsInformation controlNumber planDateInformation).each do |v|
        define_method(v) do
          @raw.dig(v)
        end
      end

      %w(eligibilityBegin planBegin service).each do |f|
        define_method(f) do
          return PARSE_DATE.call(self.date_info&.dig(f))
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
      alias_method :date_info, :planDateInformation
      alias_method :eligibility_begin_date, :eligibilityBegin
      alias_method :plan_begin_date, :planBegin
      alias_method :service_date, :service
    end
  end
end
