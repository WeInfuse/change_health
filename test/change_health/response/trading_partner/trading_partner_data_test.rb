require 'test_helper'

class TradingPartnerDataTest < Minitest::Test
  describe 'trading partner data' do
    let (:raw_response) { build_response(file: 'trading_partners_query.response.json') }
    let (:trading_partners_data) { ChangeHealth::Response::TradingPartnersData.new(JSON.parse(raw_response[:body])) }

    it "name" do
      assert_equal "Aetna Test Payer", trading_partners_data[0].name
      assert_equal "Aetna Test Payer 2", trading_partners_data[1].name
    end

    it "services" do
      services = [{"serviceName"=>"professionalClaims", "serviceConnections"=>{"direct"=>{"serviceId"=>"1234"}}, "serviceModified"=>11122233344455, "enrollmentStatus"=>"Register with payer", "acceptsSecondary"=>true, "currentStatus"=>"Active", "clearingHouse"=>"legacyExchange"}, {"serviceName"=>"claimStatus", "serviceConnections"=>{"direct"=>{"serviceId"=>"ABCDEF"}}, "serviceModified"=>1122345554321, "enrollmentStatus"=>"No enrollment required", "currentStatus"=>"Active", "clearingHouse"=>"legacyExchange"}, {"serviceName"=>"medicalEligibility", "serviceConnections"=>{"direct"=>{"serviceId"=>"ABCDEF"}}, "serviceModified"=>1122345554321, "enrollmentStatus"=>"No enrollment required", "acceptsSecondary"=>true, "currentStatus"=>"Active", "clearingHouse"=>"legacyExchange"}]
      assert_equal services, trading_partners_data[0].services
      services.last["serviceName"] = "notMedicalEligibility"
      assert_equal services, trading_partners_data[1].services
    end

    it "medical_eligibility_service" do
      first_medical_eligibility_service = {"serviceName"=>"medicalEligibility", "serviceConnections"=>{"direct"=>{"serviceId"=>"ABCDEF"}}, "serviceModified"=>1122345554321, "enrollmentStatus"=>"No enrollment required", "acceptsSecondary"=>true, "currentStatus"=>"Active", "clearingHouse"=>"legacyExchange"}
      assert_equal first_medical_eligibility_service, trading_partners_data[0].medical_eligibility_service
      assert_nil trading_partners_data[1].medical_eligibility_service
    end

    it "medical_eligibility_service_id" do
      assert_equal "ABCDEF", trading_partners_data[0].medical_eligibility_service_id
      assert_nil trading_partners_data[1].medical_eligibility_service_id
    end
  end
end
