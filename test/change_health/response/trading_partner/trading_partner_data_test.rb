require 'test_helper'

class TradingPartnerDataTest < Minitest::Test
  describe 'trading partner data' do
    let (:raw_response) { build_response(file: 'trading_partners_query.response.json') }
    let (:trading_partners_data) { ChangeHealth::Response::TradingPartnersData.new(JSON.parse(raw_response[:body])['payers']) }

    it 'name' do
      assert_equal 'Blue Cross Blue Shield of Testing', trading_partners_data[0].name
      assert_equal 'Blue Cross Blue Shield of Testing 2', trading_partners_data[1].name
    end

    it 'alias' do
      assert_equal 'Test Alias', trading_partners_data[0].alias
      assert_nil trading_partners_data[1].alias
    end

    it 'lineOfBusiness' do
      assert_equal 'Dental', trading_partners_data[0].line_of_business
      assert_equal 'Hospital', trading_partners_data[1].line_of_business
    end

    it 'planType' do
      assert_equal 'Test', trading_partners_data[0].plan_type
      assert_equal 'Test 2 Alias', trading_partners_data[1].plan_type
    end
  end
end
