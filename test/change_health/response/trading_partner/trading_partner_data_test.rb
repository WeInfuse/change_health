require 'test_helper'

class TradingPartnerDataTest < Minitest::Test
  describe 'trading partner data' do
    let (:raw_response) { build_response(file: 'trading_partners_query.response.json') }
    let (:trading_partners_data) { ChangeHealth::Response::TradingPartnersData.new(JSON.parse(raw_response[:body])['payers']) }

    it "name" do
      assert_equal "Blue Cross Blue Shield of Testing", trading_partners_data[0].name
      assert_equal "Blue Cross Blue Shield of Testing 2", trading_partners_data[1].name
    end
  end
end
