$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'change_health'

require 'minitest/autorun'
require 'webmock/minitest'
require 'byebug'

ChangeHealth.configuration.client_id     = '123'
ChangeHealth.configuration.client_secret = 'abc'
ChangeHealth.configuration.grant_type    = 'cat'

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

def auth_stub
  @auth_stub = stub_request(:post, File.join(ChangeHealth.configuration.api_endpoint, ChangeHealth::Authentication::AUTH_ENDPOINT))
    .with(body: { client_id: '123', client_secret: 'abc', grant_type: 'cat' })
    .to_return(status: 200, body: { access_token: 'let.me.in', expires_in: 3600, token_type: 'bearer' }.to_json )
end
