module ChangeHealth
  module Request
    class TradingPartner < Hashie::Trash
      ENDPOINT = '/tradingpartners/v7/partners'.freeze

      def self.query(term)
        endpoint = ENDPOINT.dup.concat("?query=#{term}&serviceName=medicalEligibility&strictFilters=true")
        response = ChangeHealth::Connection.new.request(endpoint: endpoint, verb: :get)
        trading_partners_data = ChangeHealth::Response::TradingPartnersData.new(response)
        trading_partners_data.reject! {|partner| nil == partner.medical_eligibility_service_id }
        trading_partners_data.map {|partner| ChangeHealth::Models::TradingPartner.new(name: partner.name, service_id: partner.medical_eligibility_service_id) }
      end
    end
  end
end
