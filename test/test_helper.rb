$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'change_health'

require 'minitest/autorun'
require 'webmock/minitest'
require 'byebug'

ChangeHealth.configuration.client_id     = '123'
ChangeHealth.configuration.client_secret = 'abc'
ChangeHealth.configuration.grant_type    = 'cat'

class Minitest::Test
  def load_sample(file, parse: false)
    file = File.join('test', 'samples', file)
    file_contents = nil

    if (false == File.exist?(file))
      raise "Can't find file '#{file}'."
    end

    file_contents = File.read(file)

    if (true == parse)
      if (true == file.end_with?('.json'))
        return JSON.parse(file_contents)
      end
    end

    return file_contents
  end

  def build_response(status: nil, body: nil, headers: nil, file: nil)
    response = {}

    if status.nil?
      response[:status] = 200
    elsif status.is_a?(Symbol)
      response[:status] = Rack::Utils::SYMBOL_TO_STATUS_CODE[status]
    else
      response[:status] = status
    end

    response[:headers] = headers if (headers.is_a?(Hash))

    if (true == body.is_a?(Hash))
      body = body.to_json
    elsif (false == file.nil?)
      body = load_sample(file)
    end

    response[:body] = body if (false == body.nil?)
    response[:body] ||= load_sample('success.response.json') if 200 == response[:status]

    return response
  end

  def stub_updox_request(endpoint)
    return stub_request(:post, "#{Updox::Connection.base_uri}#{endpoint}")
  end

  def stub_change_health_auth(body: nil, response: nil)
    body ||= { client_id: '123', client_secret: 'abc', grant_type: 'cat' }
    response ||= build_response(body: { access_token: 'let.me.in', expires_in: 3600, token_type: 'bearer' })

    @auth_stub = stub_request(:post, File.join(ChangeHealth.configuration.api_endpoint, ChangeHealth::Authentication::AUTH_ENDPOINT))
      .with(body: body)
      .to_return(response)
  end

  def stub_change_health(endpoint: , setup_auth: true, response: nil, verb: :post)
    response ||= build_response(body: {})

    if true == setup_auth
      stub_change_health_auth
    end

    @stub = stub_request(verb, File.join(ChangeHealth.configuration.api_endpoint, endpoint)).to_return(response)
  end
end
