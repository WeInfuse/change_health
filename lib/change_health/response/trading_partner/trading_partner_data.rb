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

      def medical_eligibility_service
        service_name == 'Eligibility'
      end
    end
  end
end
