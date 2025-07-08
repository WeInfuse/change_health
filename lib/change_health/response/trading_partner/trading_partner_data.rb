# frozen_string_literal: true

module ChangeHealth
  module Response
    class TradingPartnerData
      def initialize(trading_partner_data)
        @raw = trading_partner_data
      end

      def name
        @raw['businessName']
      end

      def service_id
        @raw['serviceId']
      end

      def service_name
        @raw['serviceName']
      end

      def alias
        @raw['alias']
      end

      def line_of_business
        @raw['lineOfBusiness']
      end

      def plan_type
        @raw['planType']
      end
    end
  end
end
