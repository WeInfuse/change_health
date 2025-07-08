# frozen_string_literal: true

module ChangeHealth
  module Response
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
      DAY = '7'
      REMAINING = '29'

      CODES = {
        out_of_pocket: OUT_OF_POCKET,
        copayment: COPAYMENT,
        coinsurance: COINSURANCE,
        non_covered: NON_COVERED,
        deductible: DEDUCTIBLE
      }.freeze
      COVERAGES = {
        individual: INDIVIDUAL,
        child: CHILD,
        employee: EMPLOYEE,
        family: FAMILY,
        employee_and_child: EMPLOYEE_AND_CHILD,
        employee_and_spouse: EMPLOYEE_AND_SPOUSE
      }.freeze
      TIMEFRAMES = {
        visit: VISIT,
        year: YEAR,
        remaining: REMAINING
      }.freeze
      MEDICARE = {
        part_a: 'MA',
        part_b: 'MB',
        primary: 'MP'
      }.freeze
      HELPERS = {
        timeQualifierCode: TIMEFRAMES,
        coverageLevelCode: COVERAGES,
        code: CODES
      }.freeze

      HELPERS.each do |key, types|
        types.each do |method, value|
          define_method("#{method}?") do
            value == self[key] || (:individual == method && self[key].nil? && medicare?)
          end
        end
      end

      def medicare?
        MEDICARE.value?(insuranceTypeCode)
      end

      %w[benefitAmount benefitPercent].each do |amount_method|
        define_method(amount_method.to_s) do
          format_amount(amount_method)
        end
      end

      %w[insuranceType insuranceTypeCode benefitsDateInformation additionalInformation].each do |method|
        define_method(method.to_s) do
          self[method]
        end
      end
      alias date_info benefitsDateInformation
      alias insurance_type insuranceType
      alias insurance_type_code insuranceTypeCode
      alias additional_info additionalInformation

      def descriptions
        data = additionalInformation || []

        data.filter_map { |info| info['description'] }
      end

      def in_plan_network?
        'Y' == self[:inPlanNetworkIndicatorCode] || (self[:inPlanNetworkIndicatorCode].nil? && medicare?)
      end
      alias in_plan? in_plan_network?
      alias in_network? in_plan_network?

      def amount
        coinsurance? ? benefitPercent : benefitAmount
      end

      def services
        self['serviceTypeCodes']&.each_with_index&.map { |stc, i| [stc, self['serviceTypes']&.at(i)] } || []
      end

      %w[eligibilityBegin eligibilityEnd planBegin planEnd service].each do |f|
        define_method(f) do
          ChangeHealth::Models::PARSE_DATE.call(date_info&.dig(f))
        end
      end
      alias eligibility_begin_date eligibilityBegin
      alias eligibility_end_date eligibilityEnd
      alias plan_begin_date planBegin
      alias plan_end_date planEnd
      alias service_date service

      def plan_date_range
        pd = date_info&.dig('plan') || ''
        pd.split('-')
      end

      def plan_date_range_start
        ChangeHealth::Models::PARSE_DATE.call(plan_date_range[0])
      end

      def plan_date_range_end
        ChangeHealth::Models::PARSE_DATE.call(plan_date_range[1])
      end

      private

      def format_amount(key)
        amt = self[key]
        amt&.to_f
      end
    end
  end
end
