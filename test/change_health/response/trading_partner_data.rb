require 'test_helper'

class TradingPartnersDataTest < Minitest::Test
  describe 'trading partner data' do
    let (:raw_trading_partner) { load_sample('trading_partners_query.response.json', parse: true).first }
    let (:trading_partner_data) { ChangeHealth::Response::TradingPartnersData.new(raw_trading_partner) }
    describe "#initialize" do
      it "sets raw" do
        refute_nil trading_partner_data.raw
        assert_equal raw_trading_partner, trading_partner_data.raw
      end
    end

    describe "name" do
      it "returns the raw_trading_partner tradingPartnerName" do
        assert_equal raw_trading_partner.dig('tradingPartnerName'), trading_partner_data.name
      end
    end

    describe "services" do
      it "returns the raw_trading_partner clearingHouses -> legacyExchange array" do
        assert_equal raw_trading_partner.dig('clearingHouses', 'legacyExchange'), trading_partner_data.services
      end
    end

    describe "medical_eligibility_service" do
      it "returns the medicalEligibility service" do
        assert_equal 'medicalEligibility', medical_eligibility_service.dig('serviceName')
      end
    end

    describe "medical_eligibility_service_id" do
      it "returns the medical_eligibility_service id" do
        assert_equal medical_eligibility_service.dig('serviceConnections', 'direct', 'serviceId'), trading_partner_data.medical_eligibility_service_id
      end
    end
  end
end
