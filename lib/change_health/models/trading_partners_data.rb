module ChangeHealth
  module Models
    class TradingPartnersData
      attr_reader :response, :trading_partners

      def initialize(response:)
        @response = response
      end

      def parsed
        @response.map {|trading_partner| ChangeHealth::Models::TradingPartnerData.new(trading_partner) }
      end
    end
  end
end
