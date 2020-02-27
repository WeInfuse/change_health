require 'httparty'
require 'hashie'
require 'change_health/version'
require 'change_health/change_health_exception'
require 'change_health/connection'
require 'change_health/authentication'

module ChangeHealth
  class Configuration
    attr_accessor :api_key, :secret

    def initialize
      @api_key  =  nil
      @secret   =  nil
    end

    def api_endpoint=(endpoint)
      Connection.base_uri(endpoint.freeze)
    end

    def api_endpoint
      return Connection.base_uri
    end

    def token_expiry_padding=(time_in_seconds)
      Authentication.token_expiry_padding = time_in_seconds
    end

    def token_expiry_padding
      return Authentication.token_expiry_padding
    end

    def to_h
      return {
        api_key: @api_key,
        secret: @secret,
        api_endpoint: api_endpoint,
        token_expiry_padding: token_expiry_padding
      }
    end

    def from_h(h)
      self.api_key = h[:api_key]
      self.secret  = h[:secret]
      self.api_endpoint = h[:api_endpoint]
      self.token_expiry_padding = h[:token_expiry_padding]

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
        ChangeHealth.configuration.token_expiry_padding = 60 if ChangeHealth.configuration.token_expiry_padding.nil?
        @connection ||= Connection.new
      end

      def release
        @connection = nil
      end
    end
  end
end
