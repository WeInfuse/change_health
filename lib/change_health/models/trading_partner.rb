module ChangeHealth
  module Models
    class TradingPartner < Hashie::Trash
      ENDPOINT = '/tradingpartners/v7/partners'.freeze

      def query(term)
        endpoint = ENDPOINT.dup.concat("?query=#{term}")
        connection = ChangeHealth::Connection.new.request(endpoint: endpoint, verb: :get)
        ChangeHealth::Models::TradingPartnersData.new(response: connection).parsed
      end
    end
  end
end
