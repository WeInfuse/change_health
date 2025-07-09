# frozen_string_literal: true

module ChangeHealth
  class Authentication
    attr_accessor :response

    AUTH_ENDPOINT = '/apip/auth/v2/token'

    def initialize
      @response     = nil
      @request_time = nil
    end

    def authenticate(base_uri: nil)
      if expires?
        base_uri ||= Connection.base_uri
        request = {
          body: {
            client_id: ChangeHealth.configuration.client_id,
            client_secret: ChangeHealth.configuration.client_secret,
            grant_type: ChangeHealth.configuration.grant_type
          },
          endpoint: AUTH_ENDPOINT
        }

        response = Connection.new.request(**request, auth: false, base_uri: base_uri)

        if false == response.ok?
          @response = nil
          raise ChangeHealthException.from_response(response, msg: 'Authentication')
        else
          @request_time = Time.now
          @response = response
        end
      end

      self
    end

    def access_token
      @response['access_token'] if @response
    end

    def expires_in
      @response['expires_in'].to_i if @response
    end

    def token_type
      @response['token_type'] if @response
    end

    def expiry
      @request_time + expires_in if @request_time && expires_in
    end

    def expires?(seconds_from_now = 60)
      return expiry.utc <= (Time.now + seconds_from_now).utc if expiry

      true
    end

    def access_header
      {
        'Authorization' => "Bearer #{access_token}"
      }
    end

    def expire!
      @response = nil
    end
  end
end
