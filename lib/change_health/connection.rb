module ChangeHealth
  class Connection
    include HTTParty

    base_uri 'https://sandbox.apis.changehealthcare.com/'.freeze

    headers 'Content-Type' => 'application/json'

    format :json

    def request(endpoint: , body: nil, headers: {}, auth: true)
      body    = body.to_json if body.is_a?(Hash)
      headers = auth_header.merge(headers) if auth

      self.class.post(endpoint, body: body, headers: headers)
    end

    private

    def auth_header
      @auth ||= Authentication.new

      return @auth.authenticate.access_header
    end
  end
end
