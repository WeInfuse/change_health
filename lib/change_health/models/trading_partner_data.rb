module ChangeHealth
  module Models
    class TradingPartnerData
      attr_reader :raw

      def initialize(data)
        @raw = data
      end

      %w(tradingPartnerId tradingPartnerName).each do |v|
        define_method(v) do
          @raw.dig(v)
        end
      end

      alias_method :trading_partner_id, :tradingPartnerId
      alias_method :trading_partner_name, :tradingPartnerName
    end
  end
end
