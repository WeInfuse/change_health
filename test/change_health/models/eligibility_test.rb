require 'test_helper'

class EligibilityTest < Minitest::Test
  describe 'eligibility' do
    let(:eligibility) { ChangeHealth::Models::Eligibility.new }

    describe 'object' do
      describe 'serializes' do
        it 'can serialize to json' do
          result = JSON.parse(eligibility.to_json)

          assert_equal(eligibility.controlNumber, result['controlNumber'])
        end

        it 'has reasonable default control number' do
          assert_equal(9, eligibility.controlNumber.size)
        end
      end
    end

    describe 'api' do
      describe '#health_check' do
        let(:response) { build_response(file: 'health_check.response.json') }
        let(:ep) { ChangeHealth::Models::Eligibility::HEALTH_CHECK_ENDPOINT }

        it 'calls health check' do
          stub_change_health(endpoint: ep, response: response, verb: :get)

          eligibility.class.health_check

          assert_requested(@stub)
        end
      end

      describe '#query' do
        let(:response) { build_response(file: '000050.example.response.json') }
        let(:ep) { ChangeHealth::Models::Eligibility::ENDPOINT }

        before do
          stub_change_health(endpoint: ep, response: response)

          @edata = eligibility.query
        end

        it 'calls health check' do
          assert_requested(@stub)
        end

        it 'returns EligibilityData object' do
          assert_equal(@edata.raw, @edata.response.parsed_response)
        end
      end
    end
  end
end
