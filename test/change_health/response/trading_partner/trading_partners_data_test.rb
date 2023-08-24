require 'test_helper'
require 'json'

class TradingPartnersDataTest < Minitest::Test
  describe '#initialize' do
    let (:raw_response) { build_response(file: 'trading_partners_query.response.json') }
    let (:trading_partners_data) { ChangeHealth::Response::TradingPartnersData.new(JSON.parse(raw_response[:body])['payers']) }

    it 'returns an Array of Response::TradingPartnerData objects' do
      assert_equal ChangeHealth::Response::TradingPartnerData, trading_partners_data.first.class
      assert_equal 2, trading_partners_data.size
    end
  end
end
