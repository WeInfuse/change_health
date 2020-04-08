require 'test_helper'

class TradingPartnersDataTest < Minitest::Test
  describe '#initialize' do
    let (:raw_response) { build_response(file: 'trading_partners_query.response.json') }
    it 'returns an Array of Models::TradingPartner objects' do
      @trading_partners = ChangeHealth::Response::TradingPartnersData.new(raw_response)
      assert_equal ChangeHealth::Models::TradingPartner, @trading_partners.first.class
      refute_nil @trading_partners.first.name
      refute_nil @trading_partners.first.id
    end
  end
end
