require 'test_helper'

class TradingPartnerTest < Minitest::Test
  describe 'object' do
    let(:trading_partner) { ChangeHealth::Models::TradingPartner.new(service_id: '1', name: 'Test Partner') }

    it 'has id' do
      assert_respond_to trading_partner, :service_id
    end

    it 'has name' do
      assert_respond_to trading_partner, :name
    end
  end
end
