module ChangeHealth
  module Request
    class TradingPartner < Hashie::Trash
      ENDPOINT = '/tradingpartners/v7/partners'.freeze

      def self.query(term)
        params = {
          query: term,
          serviceName: 'medicalEligibility',
          strictFilters: true
        }
        response = ChangeHealth::Connection.new.request(endpoint: ENDPOINT, verb: :get, query: params)
        trading_partners_data = ChangeHealth::Response::TradingPartnersData.new(response).medical_eligibility_enabled
        trading_partners_data.map {|partner| ChangeHealth::Models::TradingPartner.new(name: partner.name, service_id: partner.medical_eligibility_service_id) }
      end
    end
  end
end
