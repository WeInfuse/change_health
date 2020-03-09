require 'httparty'
require 'hashie'
require 'change_health/version'
require 'change_health/change_health_exception'
require 'change_health/connection'
require 'change_health/authentication'
require 'change_health/models/eligibility'
require 'change_health/models/eligibility_data'
require 'change_health/models/eligibility_benefit'
require 'change_health/models/encounter'
require 'change_health/models/provider'
require 'change_health/models/subscriber'

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
