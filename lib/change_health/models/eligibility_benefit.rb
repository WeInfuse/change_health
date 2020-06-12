module ChangeHealth
  module Models
    class EligibilityBenefit < Hash
      include Hashie::Extensions::MergeInitializer
      include Hashie::Extensions::IndifferentAccess

      OUT_OF_POCKET = 'G'
      COPAYMENT     = 'B'
      COINSURANCE   = 'A'
      NON_COVERED   = 'I'
      DEDUCTIBLE    = 'C'

      INDIVIDUAL    = 'IND'
      CHILD         = 'CHD'
      EMPLOYEE      = 'EMP'
      FAMILY        = 'FAM'
      EMPLOYEE_AND_CHILD  = 'ECH'
      EMPLOYEE_AND_SPOUSE = 'ESP'

      VISIT         = '27'
      SERVICE_YEAR  = '22'
      YEAR          = '23'
      YTD           = '24'
      DAY           =  '7'
      REMAINING     = '29'

      CODES = {
        out_of_pocket: OUT_OF_POCKET,
        copayment: COPAYMENT,
        coinsurance: COINSURANCE,
        non_covered: NON_COVERED,
        deductible: DEDUCTIBLE
      }
      COVERAGES = {
        individual: INDIVIDUAL,
        child: CHILD,
        employee: EMPLOYEE,
        family: FAMILY,
        employee_and_child: EMPLOYEE_AND_CHILD,
        employee_and_spouse: EMPLOYEE_AND_SPOUSE
      }
      TIMEFRAMES = {
        visit: VISIT,
        year: YEAR,
        remaining: REMAINING
      }
      MEDICARE = {
        part_a: 'MA',
        part_b: 'MB',
        primary: 'MP'
      }
      HELPERS = {
        timeQualifierCode: TIMEFRAMES,
        coverageLevelCode: COVERAGES,
        code: CODES
      }
        
      HELPERS.each do |key, types|
        types.each do |method, value|
          define_method("#{method}?") do
            value == self[key] || :individual == method && self[key].nil? && self.medicare?
          end
        end
      end

      def medicare?
        MEDICARE.values.include?(self.insuranceTypeCode)
      end

      %w(benefitAmount benefitPercent).each do |amount_method|
        define_method("#{amount_method}") do
          format_amount(amount_method)
        end
      end

      %w(insuranceType insuranceTypeCode benefitsDateInformation additionalInformation).each do |method|
        define_method("#{method}") do
          self[method]
        end
      end
      alias_method :date_info, :benefitsDateInformation
      alias_method :insurance_type, :insuranceType
      alias_method :insurance_type_code, :insuranceTypeCode
      alias_method :additional_info, :additionalInformation

      def descriptions
        data = self.additionalInformation || []

        data.map {|info| info['description'] }.compact
      end

      def in_plan_network?
        return 'Y' == self[:inPlanNetworkIndicatorCode] || self[:inPlanNetworkIndicatorCode].nil? && self.medicare?
      end
      alias_method :in_plan?, :in_plan_network?
      alias_method :in_network?, :in_plan_network?

      def amount
        self.coinsurance? ? self.benefitPercent : self.benefitAmount
      end

      def services 
        self['serviceTypeCodes']&.each_with_index&.map {|stc, i| [stc, self['serviceTypes']&.at(i)]} || []
      end

      %w(eligibilityBegin eligibilityEnd planBegin planEnd service).each do |f|
        define_method(f) do
          return ChangeHealth::Models::EligibilityData::PARSE_DATE.call(self.date_info&.dig(f))
        end
      end
      alias_method :eligibility_begin_date, :eligibilityBegin
      alias_method :eligibility_end_date, :eligibilityEnd
      alias_method :plan_begin_date, :planBegin
      alias_method :plan_end_date, :planEnd
      alias_method :service_date, :service

      def plan_date_range
        pd = self.date_info&.dig('plan') || ''
        pd.split('-')
      end

      def plan_date_range_start
        ChangeHealth::Models::EligibilityData::PARSE_DATE.call(self.plan_date_range[0])
      end

      def plan_date_range_end
        ChangeHealth::Models::EligibilityData::PARSE_DATE.call(self.plan_date_range[1])
      end

      private
      def format_amount(key)
        amt = self[key]
        amt = amt.to_f unless amt.nil?
      end
    end
  end
end
