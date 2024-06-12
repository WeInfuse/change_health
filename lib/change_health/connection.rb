module ChangeHealth
  class Connection
    URI_BUILDER = ->(host) { "https://#{host}apigw.changehealthcare.com/".freeze }

    QA_ENDPOINT   = URI_BUILDER.call('sandbox.')
    PROD_ENDPOINT = URI_BUILDER.call('')

    include HTTParty

    base_uri QA_ENDPOINT

    headers 'Content-Type' => 'application/json;charset=UTF-8'

    format :json

    def request(
      endpoint:,
      query: nil,
      body: nil,
      headers: {},
      auth: true,
      verb: :post,
      base_uri: nil,
      auth_headers: nil
    )
      base_uri ||= Connection.base_uri
      body    = body.to_json if body.is_a?(Hash)
      headers = {} if headers.nil?
      headers = auth_header(base_uri: base_uri, auth_headers: auth_headers).merge(headers) if auth

      self.class.send(verb.to_s, endpoint, query: query, body: body, headers: headers, base_uri: base_uri)
    end

    def self.endpoint_for(klass, default_endpoint: nil)
      endpoint_options = ChangeHealth.configuration.endpoints || {}
      default_endpoint ||= klass::ENDPOINT

      endpoint_options[klass.to_s] || endpoint_options[klass.to_s.to_sym] || default_endpoint
    end

    private

    def auth_header(base_uri: nil, auth_headers: nil)
      auth_headers ||= ChangeHealth.configuration.auth_headers

      if auth_headers.nil? || auth_headers.empty?
        @auth ||= Authentication.new

        @auth.authenticate(base_uri: base_uri).access_header
      else
        auth_headers
      end
    end
  end
end
