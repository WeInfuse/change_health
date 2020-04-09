module ChangeHealth
  module Response
    class TradingPartnersData < Array
      def initialize(trading_partners)
        super(trading_partners.map {|trading_partner| ChangeHealth::Response::TradingPartnerData.new(trading_partner) })
      end

      def medical_eligibility_enabled
        self.reject {|partner| nil == partner.medical_eligibility_service_id }
      end
    end
  end
end
