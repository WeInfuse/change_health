require 'httparty'
require 'hashie'
require 'change_health/version'
require 'change_health/authentication'
require 'change_health/change_health_exception'
require 'change_health/connection'
require 'change_health/extensions'
require 'change_health/models/error'
require 'change_health/models/model'
require 'change_health/models/claim/submission/claim_information'
require 'change_health/models/claim/submission/provider'
require 'change_health/models/claim/submission/service_line'
require 'change_health/models/claim/submission/submitter'
require 'change_health/models/claim/submission/subscriber'
require 'change_health/models/eligibility/encounter'
require 'change_health/models/eligibility/provider'
require 'change_health/models/eligibility/subscriber'
require 'change_health/models/trading_partner/trading_partner'
require 'change_health/request/eligibility'
require 'change_health/request/submission'
require 'change_health/request/trading_partner'
require 'change_health/response/response_data'
require 'change_health/response/claim/submission/submission_data'
require 'change_health/response/eligibility/eligibility_benefit'
require 'change_health/response/eligibility/eligibility_benefits'
require 'change_health/response/eligibility/eligibility_data'
require 'change_health/response/trading_partner/trading_partner_data'
require 'change_health/response/trading_partner/trading_partners_data'

module ChangeHealth
  class Configuration
    attr_accessor :client_id, :client_secret, :grant_type

    def initialize
      @client_id     = nil
      @client_secret = nil
      @grant_type    = :client_credentials
    end

    def api_endpoint=(endpoint)
      Connection.base_uri(endpoint.freeze)
    end

    def api_endpoint
      return Connection.base_uri
    end

    def to_h
      return {
        client_id: @client_id,
        client_secret: @client_secret,
        grant_type: @grant_type,
        api_endpoint: api_endpoint
      }
    end

    def from_h(h)
      self.client_id     = h[:client_id]
      self.client_secret = h[:client_secret]
      self.grant_type    = h[:grant_type]
      self.api_endpoint  = h[:api_endpoint]

      return self
    end
  end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end

  # ChangeHealth API client
  class ChangeHealthClient
    class << self
      def connection
        @connection ||= Connection.new
      end

      def release
        @connection = nil
      end
    end
  end
end
