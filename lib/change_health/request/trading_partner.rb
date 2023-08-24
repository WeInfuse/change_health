module ChangeHealth
  module Request
    class TradingPartner < Hashie::Trash
      ENDPOINT = '/medicalnetwork/payerfinder/v1/payers'.freeze

      def self.query(term)
        params = {
          businessName: term,
          serviceName: 'Eligibility'
        }

        response = ChangeHealth::Connection.new.request(endpoint: ENDPOINT, verb: :get, query: params)
        trading_partners_data = ChangeHealth::Response::TradingPartnersData.new(response['payers'])
        trading_partners_data.map { |partner| ChangeHealth::Models::TradingPartner.new(name: partner.name, service_id: partner.service_id) }
      end
    end
  end
end
