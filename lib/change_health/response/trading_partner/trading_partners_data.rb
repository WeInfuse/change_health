# frozen_string_literal: true

module ChangeHealth
  module Response
    class TradingPartnersData < Array
      def initialize(trading_partners)
        super((trading_partners || []).map do |trading_partner|
          ChangeHealth::Response::TradingPartnerData.new(trading_partner)
        end)
      end
    end
  end
end
