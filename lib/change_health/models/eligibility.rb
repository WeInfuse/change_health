module ChangeHealth
  module Models
    class Eligibility < Hashie::Trash
      ENDPOINT = '/medicalnetwork/eligibility/v3'.freeze
      HEALTH_CHECK_ENDPOINT = ENDPOINT + '/healthcheck'.freeze

      property :controlNumber, from: :control_number, required: true, default: ->() { '%09d' % rand(1_000_000_000) }
      property :dependents, required: false
      property :encounter, required: false
      property :informationReceiverName, from: :information_receiver_name, required: false
      property :partnerId, from: :partner_id, default: true
      property :portalPassword, from: :portal_password, required: false
      property :portalUsername, from: :portal_username, required: false
      property :provider, required: false
      property :subscriber, required: false
      property :tradingPartnerId, from: :trading_partner_id, required: false
      property :tradingPartnerServiceId, from: :trading_partner_service_id, required: false

      alias_method :partnerId?, :partnerId
      alias_method :partner_id?, :partnerId

      def add_dependent(dependent)
        self[:dependent] ||= []
        self[:dependent] << dependent
      end

      def query
        ChangeHealth::Connection.new.request(endpoint: ENDPOINT, body: self.to_h)
      end

      def self.health_check
        ChangeHealth::Connection.new.request(endpoint: HEALTH_CHECK_ENDPOINT, verb: :get)
      end

      def self.ping
        self.health_check
      end
    end
  end
end
