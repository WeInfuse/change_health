module ChangeHealth
  class Connection
    URI_BUILDER = ->(host) { "https://#{host}apigw.changehealthcare.com/".freeze }

    QA_ENDPOINT   = URI_BUILDER.call('sandbox.')
    PROD_ENDPOINT = URI_BUILDER.call('')

    include HTTParty

    base_uri QA_ENDPOINT

    headers 'Content-Type' => 'application/json;charset=UTF-8'

    format :json

    def request(endpoint:, query: nil, body: nil, headers: {}, auth: true, verb: :post)
      body    = body.to_json if body.is_a?(Hash)
      headers = {} if headers.nil?
      headers = auth_header.merge(headers) if auth

      self.class.send(verb.to_s, endpoint, query: query, body: body, headers: headers)
    end

    def self.endpoint_for(klass)
      endpoint_options = ChangeHealth.configuration.endpoints || {}

      endpoint_options[klass.to_s] || endpoint_options[klass.to_s.to_sym] || klass::ENDPOINT
    end

    private

    def auth_header
      if ChangeHealth.configuration.auth_headers.nil?
        @auth ||= Authentication.new

        @auth.authenticate.access_header
      else
        ChangeHealth.configuration.auth_headers
      end
    end
  end
end
