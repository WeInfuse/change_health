# frozen_string_literal: true

module ChangeHealth
  module Request
    class TradingPartner < Hashie::Trash
      ENDPOINT = '/medicalnetwork/payerfinder/v1/payers'

      def self.query(term, service_name: 'Eligibility', clearing_house: 'npd')
        params = {
          businessName: term,
          serviceName: service_name,
          clearingHouse: clearing_house
        }

        response = ChangeHealth::Connection.new.request(endpoint: ENDPOINT, verb: :get, query: params)
        trading_partners_data = ChangeHealth::Response::TradingPartnersData.new(response['payers'])
        trading_partners_data.map { |partner| ChangeHealth::Models::TradingPartner.new(name: partner.name, alias: partner.alias, line_of_business: partner.line_of_business, plan_type: partner.plan_type, service_id: partner.service_id) }
      end
    end
  end
end
