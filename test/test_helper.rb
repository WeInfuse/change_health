$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'change_health'

require 'minitest/autorun'
require 'webmock/minitest'
require 'byebug'

ChangeHealth.configuration.api_key = '123'
ChangeHealth.configuration.secret  = 'abc'

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
    .with(body: { apiKey: '123', secret: 'abc' })
    .to_return(status: 200, body: { accessToken: 'let.me.in', expires: (Time.now + 60).utc.strftime('%Y-%m-%dT%H:%M:%S.%6NZ'), refreshToken: 'rtoken' }.to_json )
end

def refresh_stub
  @refresh_stub = stub_request(:post, File.join(ChangeHealth.configuration.api_endpoint, ChangeHealth::Authentication::REFRESH_ENDPOINT))
    .with(body: { apiKey: '123', refreshToken: 'rtoken' })
    .to_return(status: 200, body: { accessToken: 'let.me.in.again', expires: (Time.now + 60).utc.strftime('%Y-%m-%dT%H:%M:%S.%6NZ'), refreshToken: 'rtoken' }.to_json )
end
