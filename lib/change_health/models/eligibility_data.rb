module ChangeHealth
  module Models
    class EligibilityData
      attr_reader :response, :raw

      OUT_OF_POCKET = 'G'
      COPAYMENT     = 'B'
      COINSURANCE   = 'A'
      NON_COVERED   = 'I'

      INDIVIDUAL    = 'IND'
      CHILD         = 'CHD'

      VISIT         = '27'
      YEAR          = '23'
      REMAINING     = '29'

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

      %w(planStatus benefitsInformation).each do |v|
        define_method(v) do
          @raw.dig(v) || {}
        end
      end

      def plan_status(service_code: )
        self.planStatus&.find {|plan| plan.dig('serviceTypeCodes').include?(service_code) } || {}
      end

      def benefits(service_code: )
        self.benefitsInformation&.select {|benefit| benefit.dig('serviceTypeCodes')&.include?(service_code) } || []
      end

      def individual_coinsurance(service_code: , time_qualifier: )
        data = self.benefits(service_code: service_code).find {|benefit| benefit['timeQualifierCode'] == time_qualifier && benefit['code'] == COINSURANCE && benefit['coverageLevelCode'] == INDIVIDUAL }

        amount(data, key: 'benefitPercent')
      end

      def individual_coinsurance_visit(service_code: )
        individual_coinsurance(service_code: service_code, time_qualifier: VISIT)
      end

      def individual_copayment(service_code: , time_qualifier: )
        data = self.benefits(service_code: service_code).find {|benefit| benefit['timeQualifierCode'] == time_qualifier && benefit['code'] == COPAYMENT && benefit['coverageLevelCode'] == INDIVIDUAL }

        amount(data)
      end

      def individual_copayment_visit(service_code: )
        individual_copayment(service_code: service_code, time_qualifier: VISIT)
      end

      def individual_oop(service_code: , time_qualifier: )
        data = self.benefits(service_code: service_code).find {|benefit| benefit['timeQualifierCode'] == time_qualifier && benefit['code'] == OUT_OF_POCKET && benefit['coverageLevelCode'] == INDIVIDUAL }

        amount(data)
      end

      def individual_oop_remaining(service_code: )
        individual_oop(service_code: service_code, time_qualifier: REMAINING)
      end

      def individual_oop_total(service_code: )
        individual_oop(service_code: service_code, time_qualifier: YEAR)
      end

      private
      def amount(data, key: 'benefitAmount')
        amt = data[key.to_s] unless data.nil?
        amt = amt.to_f unless amt.nil?
      end
    end
  end
end
