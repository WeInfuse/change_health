module ChangeHealth
  module Request
    class TradingPartner < Hashie::Trash
      ENDPOINT = '/tradingpartners/v7/partners'.freeze

      def self.query(term)
        endpoint = ENDPOINT.dup.concat("?query=#{term}")
        response = ChangeHealth::Connection.new.request(endpoint: endpoint, verb: :get)
        ChangeHealth::Response::TradingPartnersData.new(response)
      end
    end
  end
end
