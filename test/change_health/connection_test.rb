require 'test_helper'

class ConnectionTest < Minitest::Test
  describe 'connection' do
    let(:fake_endpoint) { '/blahblah' }

    before do
      stub_change_health(endpoint: fake_endpoint)

      @connection = ChangeHealth::Connection.new

      WebMock.after_request do |request, _response|
        @request = request
      end
    end

    describe 'auth option' do
      it 'defaults to sending auth header' do
        @connection.request(endpoint: fake_endpoint)

        assert_requested(@auth_stub, times: 1)
        assert_requested(@stub, times: 1)
      end

      it 'false omits auth header' do
        @connection.request(auth: false, endpoint: fake_endpoint)

        assert_requested(@stub, times: 1)
      end

      describe 'headers are overridden' do
        before do
          @config = ChangeHealth.configuration.to_h
        end

        after do
          ChangeHealth.configuration.from_h(@config)
        end

        it 'honors the header' do
          override_headers = { Authorization: 'mytoken', other_header: 'hi' }
          ChangeHealth.configuration.auth_headers = override_headers

          @connection.request(endpoint: fake_endpoint)

          assert_not_requested(@auth_stub)
          assert_requested(@stub, times: 1)
          assert_equal('mytoken', @request.headers['Authorization'])
          assert_equal('hi', @request.headers['Other-Header'])
        end

        it 'can override on a per-request basis' do
          override_headers = { Authorization: 'mytoken', other_header: 'hi' }

          @connection.request(endpoint: fake_endpoint, auth_headers: override_headers)

          assert_not_requested(@auth_stub)
          assert_requested(@stub, times: 1)
          assert_equal('mytoken', @request.headers['Authorization'])
          assert_equal('hi', @request.headers['Other-Header'])
        end

        it 'can override to auth endpoint on a per-request basis' do
          # set default headers so we can assert they are overridden
          default_headers = { Authorization: 'mytoken', other_header: 'hi' }
          ChangeHealth.configuration.auth_headers = default_headers

          override_headers = {}

          @connection.request(endpoint: fake_endpoint, auth_headers: override_headers)

          assert_requested(@auth_stub, times: 1)
          assert_requested(@stub, times: 1)
        end
      end
    end

    it 'returns response' do
      response = @connection.request(endpoint: fake_endpoint)

      assert(response.ok?)
      assert_equal({}, response.parsed_response)
      assert_equal('{}', response.body)
    end

    it 'changes body to json for hashes' do
      @connection.request(auth: false, body: { h: 10 }, endpoint: fake_endpoint)

      assert_requested(@stub, times: 1)
      assert_equal({ h: 10 }.to_json, @request.body)
    end

    it 'changes body to json for hashes' do
      @connection.request(auth: false, body: 'hi', endpoint: fake_endpoint)

      assert_requested(@stub, times: 1)
      assert_equal('hi', @request.body)
    end

    it 'passes headers' do
      @connection.request(headers: { 'x' => '10' }, endpoint: fake_endpoint)

      assert_requested(@stub, times: 1)
      assert_equal('10', @request.headers['X'])
    end

    it 'has precedence over auth header' do
      @connection.request(headers: { 'Authorization' => 'eep' }, endpoint: fake_endpoint)

      assert_requested(@stub, times: 1)
      assert_equal('eep', @request.headers['Authorization'])
    end

    it 'can override base uri per request' do
      stub_change_health(endpoint: fake_endpoint, base_uri: 'different.uri')
      @connection.request(endpoint: fake_endpoint, base_uri: 'different.uri')

      assert_requested(@stub, times: 1)
    end

    describe '#endpoint_for' do
      before do
        @config = ChangeHealth.configuration.to_h
      end

      after do
        ChangeHealth.configuration.from_h(@config)
      end

      it 'returns default endpoint for class if no default specified' do
        assert_equal(
          ChangeHealth::Request::Eligibility::ENDPOINT,
          ChangeHealth::Connection.endpoint_for(ChangeHealth::Request::Eligibility)
        )
      end

      it 'returns inputted default if no configuration' do
        default_endpoint = 'blahblah'
        assert_equal(
          default_endpoint,
          ChangeHealth::Connection.endpoint_for(
            ChangeHealth::Request::Eligibility,
            default_endpoint: default_endpoint
          )
        )
      end

      it 'uses configuration over default' do
        new_endpoint = '/someotherendpoint'

        ChangeHealth.configuration.endpoints = { 'ChangeHealth::Request::Eligibility' => new_endpoint }

        assert_equal(
          new_endpoint,
          ChangeHealth::Connection.endpoint_for(
            ChangeHealth::Request::Eligibility,
            default_endpoint: 'blahblah'
          )
        )
      end

      it 'works with symbols' do
        new_endpoint = '/someotherendpoint'

        ChangeHealth.configuration.endpoints = { 'ChangeHealth::Request::Eligibility': new_endpoint }

        assert_equal(new_endpoint, ChangeHealth::Connection.endpoint_for(ChangeHealth::Request::Eligibility))
      end
    end
  end
end
