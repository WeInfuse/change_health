module ChangeHealth
  class Connection
    URI_BUILDER = ->(host) { "https://#{host}apis.changehealthcare.com/".freeze }

    QA_ENDPOINT   = URI_BUILDER.call('sandbox.')
    PROD_ENDPOINT = URI_BUILDER.call('')

    include HTTParty

    base_uri QA_ENDPOINT

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
