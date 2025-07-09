$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'change_health'

require 'minitest/autorun'
require 'webmock/minitest'
require 'byebug'

ChangeHealth.configuration.client_id     = '123'
ChangeHealth.configuration.client_secret = 'abc'
ChangeHealth.configuration.grant_type    = 'cat'

module Minitest
  class Test
    def load_sample(file, parse: false)
      file = File.join('test', 'samples', file)

      raise "Can't find file '#{file}'." if false == File.exist?(file)

      file_contents = File.read(file)

      return JSON.parse(file_contents) if (true == parse) && (true == file.end_with?('.json'))

      file_contents
    end

    def build_response(status: 200, body: nil, headers: nil, file: nil)
      response = {}

      response[:status] = status.is_a?(Symbol) ? Rack::Utils::SYMBOL_TO_STATUS_CODE[status] : status
      response[:headers] = headers if headers.is_a?(Hash)

      response[:body] = body.is_a?(Hash) ? body.to_json : load_sample(file)
      response[:body] ||= load_sample('success.response.json') if 200 == response[:status]

      response
    end

    def stub_change_health_auth(body: nil, response: nil, base_uri: nil)
      base_uri ||= ChangeHealth.configuration.api_endpoint
      body ||= { client_id: '123', client_secret: 'abc', grant_type: 'cat' }
      response ||= build_response(body: { access_token: 'let.me.in', expires_in: 3600, token_type: 'bearer' })

      @auth_stub = stub_request(:post, File.join(base_uri, ChangeHealth::Authentication::AUTH_ENDPOINT))
                   .with(body: body)
                   .to_return(response)
    end

    def stub_change_health(endpoint:, setup_auth: true, response: nil, verb: :post, base_uri: nil)
      base_uri ||= ChangeHealth.configuration.api_endpoint
      response ||= build_response(body: {})

      stub_change_health_auth(base_uri: base_uri) if true == setup_auth

      @stub = stub_request(verb, File.join(base_uri, endpoint)).to_return(response)
    end
  end
end
