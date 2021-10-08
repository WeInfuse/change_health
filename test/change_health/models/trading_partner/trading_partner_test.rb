require 'test_helper'

class TradingPartnerTest < Minitest::Test

  describe "object" do
    let(:trading_partner) { ChangeHealth::Models::TradingPartner.new(service_id: '1', name: 'Test Partner') }

    it "has id" do
      assert trading_partner.respond_to?(:service_id)
    end

    it "has name" do
      assert trading_partner.respond_to?(:name)
    end
  end
end
