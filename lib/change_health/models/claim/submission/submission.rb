module ChangeHealth
  module Models
    module Claim
      class Submission < Hashie::Trash
        ENDPOINT = '/medicalnetwork/professionalclaims/v3'.freeze
        HEALTH_CHECK_ENDPOINT = ENDPOINT + '/healthcheck'.freeze
        SUBMISSION_ENDPOINT = ENDPOINT + '/submission'.freeze

        property :claimInformation, from: :claim_information, required: false
        property :controlNumber, from: :control_number, required: true, default: ChangeHealth::Models::CONTROL_NUMBER
        property :providers, required: false
        property :receiver, required: false
        property :submitter, required: false
        property :subscriber, required: false
        # Need one or the other, trading partner id or trading partner service id
        property :tradingPartnerId, from: :trading_partner_id, required: false
        property :tradingPartnerServiceId, from: :trading_partner_service_id, required: false

        def add_provider(provider)
          self[:providers] ||= []
          self[:providers] << provider
        end

        def submission
          ChangeHealth::Models::Claim::SubmissionData.new(response: ChangeHealth::Connection.new.request(endpoint: SUBMISSION_ENDPOINT, body: self.to_h))
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
end
