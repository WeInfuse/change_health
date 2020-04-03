module ChangeHealth
  class Authentication
    attr_accessor :response

    AUTH_ENDPOINT    = '/apip/auth/v2/token'.freeze

    def initialize
      @response     = nil
      @request_time = nil
    end

    def authenticate
      if (self.expires?)
        request = {
          body: { client_id: ChangeHealth.configuration.client_id, client_secret: ChangeHealth.configuration.client_secret, grant_type: ChangeHealth.configuration.grant_type },
          endpoint: AUTH_ENDPOINT
        }

        response = Connection.new.request(**request, auth: false)

        if (false == response.ok?)
          @response = nil
          raise ChangeHealthException.from_response(response, msg: 'Authentication')
        else
          @request_time = Time.now
          @response = response
        end
      end

      return self
    end

    def access_token
      return @response['access_token'] if @response
    end

    def expires_in
      return @response['expires_in'].to_i if @response
    end

    def token_type
      return @response['token_type'] if @response
    end

    def expiry
      @request_time + self.expires_in if @request_time && self.expires_in
    end

    def expires?(seconds_from_now = 60)
      if (self.expiry)
        return self.expiry.utc <= (Time.now + seconds_from_now).utc
      else
        return true
      end
    end

    def access_header
      return {
        'Authorization' => "Bearer #{self.access_token}",
      }
    end

    def expire!
      @response = nil
    end
  end
end
