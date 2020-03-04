module ChangeHealth
  class Connection
    include HTTParty

    base_uri 'https://sandbox.apis.changehealthcare.com/'.freeze

    headers 'Content-Type' => 'application/json;charset=UTF-8'

    format :json

    def request(endpoint: , body: nil, headers: {}, auth: true, verb: :post)
      body    = body.to_json if body.is_a?(Hash)
      headers = auth_header.merge(headers) if auth

      self.class.send("#{verb}", endpoint, body: body, headers: headers)
    end

    private

    def auth_header
      @auth ||= Authentication.new

      return @auth.authenticate.access_header
    end
  end
end
