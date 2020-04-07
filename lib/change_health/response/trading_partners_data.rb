module ChangeHealth
  module Response
    class TradingPartnersData < Array
      def initialize(trading_partners)
        super(trading_partners.map {|trading_partner| ChangeHealth::Models::TradingPartner.new(trading_partner) })
      end
    end
  end
end
