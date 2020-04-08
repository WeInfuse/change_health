module ChangeHealth
  module Response
    class TradingPartnerData
      def initialize(trading_partner_data)
        @raw = trading_partner_data
      end

      def name
        @raw.dig('tradingPartnerName')
      end

      def services
        @raw.dig('clearingHouses', 'legacyExchange')
      end

      def medical_eligibility_service
        return nil unless services
        services.detect {|service| service.dig('serviceName') == 'medicalEligibility' }
      end

      def medical_eligibility_service_id
        return nil unless medical_eligibility_service
        medical_eligibility_service.dig('serviceConnections', 'direct', 'serviceId')
      end
    end
  end
end
