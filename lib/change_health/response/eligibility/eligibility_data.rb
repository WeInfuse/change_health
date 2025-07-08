# frozen_string_literal: true

module ChangeHealth
  module Response
    class EligibilityData < ChangeHealth::Response::ResponseData
      ACTIVE = '1'
      INACTIVE = '6'

      def active?(service_code: '30')
        plan_status(service_code: service_code, single: false).any? { |status| ACTIVE == status['statusCode'] }
      end

      def inactive?(service_code: '30')
        plan_status(service_code: service_code, single: false).any? { |status| INACTIVE == status['statusCode'] }
      end

      def dependents?
        true == dependents&.any?
      end

      %w[planStatus benefitsInformation controlNumber planDateInformation dependents].each do |v|
        define_method(v) do
          @raw[v]
        end
      end

      %w[eligibilityBegin planBegin service].each do |f|
        define_method(f) do
          ChangeHealth::Models::PARSE_DATE.call(date_info&.dig(f))
        end
      end
      alias eligibility_begin_date eligibilityBegin
      alias plan_begin_date planBegin
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

      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      def plan_status(service_code:, single: true)
        if true == single
          planStatus&.find { |plan| plan['serviceTypeCodes']&.include?(service_code) } || {}
        else
          planStatus&.select { |plan| plan['serviceTypeCodes']&.include?(service_code) } || []
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/PerceivedComplexity

      def benefits
        kname   = "ChangeHealth::Response::EligibilityBenefits#{trading_partner_id&.upcase}"
        klazz   = Object.const_get(kname) if Module.const_defined?(kname)
        klazz ||= ChangeHealth::Response::EligibilityBenefits

        klazz = klazz.factory(self) if klazz.respond_to?(:factory)

        klazz.new(benefitsInformation || [])
      end

      def medicare?(**kwargs)
        false == benefits.empty? && benefits.where(**kwargs).all?(&:medicare?)
      end

      def plan?(name)
        plan_names.any?(name)
      end

      def plan_names
        planStatus&.filter_map { |plan_status| plan_status['planDetails'] } || []
      end

      def trading_partner?(name)
        trading_partner_id == name
      end

      def trading_partner_id
        @raw['tradingPartnerServiceId']
      end

      alias control_number controlNumber
      alias benefits_information benefitsInformation
      alias plan_statuses planStatus
      alias date_info planDateInformation
    end
  end
end
