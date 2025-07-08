require 'test_helper'

class ChangeHealthTest < Minitest::Test
  describe 'change_health' do
    it 'has a version' do
      assert_equal(false, ChangeHealth::VERSION.nil?)
    end
  end

  describe '#connection' do
    it 'returns a connection object' do
      assert_kind_of(ChangeHealth::Connection, ChangeHealth::ChangeHealthClient.connection)
    end
  end

  describe 'configuration' do
    before do
      @config = ChangeHealth.configuration.to_h
    end

    after do
      ChangeHealth.configuration.from_h(@config)
    end

    {
      auth_headers: { a: 'b', c: 'd' },
      client_id: 'a',
      client_secret: 'b',
      endpoints: { SomeClass: '/abc' },
      grant_type: 'c',
      api_endpoint: 'http://hi.com'
    }.each do |method, value|
      it "can set #{method} via configuration" do
        assert_respond_to(ChangeHealth.configuration, method)
        ChangeHealth.configuration.send("#{method}=", value)

        assert_equal(value, ChangeHealth.configuration.send(method.to_s))
      end

      it "can set #{method} via configure block" do
        ChangeHealth.configure do |c|
          assert_respond_to(c, method)
          c.send("#{method}=", value)

          assert_equal(value, ChangeHealth.configuration.send(method.to_s))
        end
      end
    end
  end
end
