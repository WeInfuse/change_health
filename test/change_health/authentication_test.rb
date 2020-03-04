require 'test_helper'

class AuthenticationTest < Minitest::Test
  describe 'authentication' do
    let(:auth) { ChangeHealth::Authentication.new }

    before do
      stub_change_health_auth

      @config = ChangeHealth.configuration.to_h
    end

    after do
      ChangeHealth.configuration.from_h(@config)
    end

    describe 'authentication' do
      it 'calls change_health endpoint' do
        auth.authenticate
        assert_requested(@auth_stub, times: 1)
      end

      it 'makes no calls when token wont expire inside padding time' do
        auth.authenticate
        auth.authenticate

        assert_requested(@auth_stub, times: 1)

        assert_equal('let.me.in', auth.access_token)
      end

      it 'fails with a resonable exception and with nil response' do
        stub_request(:post, File.join(ChangeHealth.configuration.api_endpoint, ChangeHealth::Authentication::AUTH_ENDPOINT))
          .with(body: { client_id: 'wrong', client_secret: ChangeHealth.configuration.client_secret, grant_type: ChangeHealth.configuration.grant_type })
          .to_return(build_response(file: 'error_response.json', status: 401))

        auth.expire!

        key = ChangeHealth.configuration.client_id
        ChangeHealth.configuration.client_id = 'wrong'

        error = assert_raises(ChangeHealth::ChangeHealthException) { auth.authenticate }

        ChangeHealth.configuration.client_id = key

        assert_match(/Failed Authenticat/, error.message)
        assert_match(/HTTP code: 401/, error.message)
        assert_match(/MSG: Invalid request/, error.message)
        assert_nil(auth.response)
      end
    end

    describe 'responses' do
      before do
        auth.authenticate
      end

      it 'has an access token' do
        assert_equal('let.me.in', auth.access_token)
      end

      it 'can create the auth header' do
        assert_equal('let.me.in', auth.access_token)
      end
    end

    describe '#expires?' do
      before do
        auth.authenticate
      end

      it 'is true when token is too close to expire padding' do
        assert(auth.expires?(3600))
      end

      it 'is false when token is far enough from expire' do
        assert_equal(false, auth.expires?(0))
      end
    end
  end
end
