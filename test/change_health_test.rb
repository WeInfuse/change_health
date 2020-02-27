require 'test_helper'

class ChangeHealthTest < Minitest::Test
  PATIENT = {
      Identifiers: [],
      Demographics: {
        FirstName: 'Joe'
      }
  }.freeze

  describe 'change_health' do
    it 'has a version' do
      assert_equal(false, ChangeHealth::VERSION.nil?)
    end
  end

  describe '#connection' do
    it 'sets a default expiry padding' do
      ChangeHealth.configuration.token_expiry_padding = nil
      ChangeHealth::ChangeHealthClient.connection
      assert_equal(60, ChangeHealth.configuration.token_expiry_padding)
    end

    it 'returns a connection object' do
      assert(ChangeHealth::ChangeHealthClient.connection.is_a?(ChangeHealth::Connection))
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
      api_key: 'a',
      secret: 'b',
      api_endpoint: 'http://hi.com',
      token_expiry_padding: 123
    }.each do |method, value|
      it "can set #{method} via configuration" do
        assert(ChangeHealth.configuration.respond_to?(method))
        ChangeHealth.configuration.send("#{method}=", value)

        assert_equal(value, ChangeHealth.configuration.send("#{method}"))
      end

      it "can set #{method} via configure block" do
        ChangeHealth.configure do |c|
          assert(c.respond_to?(method))
          c.send("#{method}=", value)

          assert_equal(value, ChangeHealth.configuration.send("#{method}"))
        end
      end
    end
  end
end
