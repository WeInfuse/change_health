require 'test_helper'

class TradingPartnerRequestTest < Minitest::Test
  describe 'trading partner' do
    let(:trading_partner) { ChangeHealth::Request::TradingPartner }

    describe 'api' do
      describe '#query' do
        let(:response) { build_response(file: 'trading_partners_query.response.json') }
        let(:search_term) { 'Test' }
        let(:ep) { ChangeHealth::Request::TradingPartner::ENDPOINT.dup.concat("?businessName=#{search_term}&serviceName=Eligibility") }

        before do
          stub_change_health(endpoint: ep, response: response, verb: :get)

          @trading_partners = trading_partner.query(search_term)
        end

        it 'calls the trading_partner query endpoint' do
          assert_requested(@stub)
        end

        it 'returns an Array of Models::TradingPartner objects' do
          assert_equal ChangeHealth::Models::TradingPartner, @trading_partners.first.class
          refute_nil @trading_partners.first.name
          refute_nil @trading_partners.first.service_id
        end
      end
    end
  end
end
