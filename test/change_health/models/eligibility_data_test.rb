require 'test_helper'

class EligibilityDataTest < Minitest::Test
  class FakeResponse
    def initialize(response)
      @response = response
    end

    def parsed_response
      @response.call
    end
  end

  describe 'eligibility data' do
    let(:json_data) { load_sample('000050.example.response.json', parse: true) }
    let(:edata) { ChangeHealth::Models::EligibilityData.new(data: json_data) }
    let(:edata_empty) { ChangeHealth::Models::EligibilityData.new }
    let(:edata_inactive) { ChangeHealth::Models::EligibilityData.new(data: load_sample('000041.example.response.json', parse: true)) }

    describe 'object' do
      describe '#initialize' do
        it 'can take data' do
          assert(false == edata.nil?)
        end

        it 'can take a response' do
          ed = ChangeHealth::Models::EligibilityData.new(response: FakeResponse.new(->() { 'hi' }))
          assert(false == ed.nil?)
        end

        it 'defaults to empty' do
          assert(false == edata_empty.nil?)
        end

        it 'handles bad response gracefully' do
          ed = ChangeHealth::Models::EligibilityData.new(response: FakeResponse.new(->() { JSON.parse('bad json') }))
          assert(false == ed.nil?)
        end

        it 'does not handle other erros gracefully' do
          assert_raises { ChangeHealth::Models::EligibilityData.new(response: FakeResponse.new(->() { nil.say_hi! })) }
        end
      end

      describe '#plan_status' do
        it 'returns plan status data' do
          assert_equal(edata.planStatus.first.keys.size, edata.plan_status(service_code: '30').keys.size)
        end

        describe 'returns empty hash' do
          it 'empty data' do
            assert(edata_empty.plan_status(service_code: '30').empty?)
          end

          it 'for non matched code' do
            assert(edata.plan_status(service_code: 'cat').empty?)
          end
        end
      end

      describe '#benefits' do
        it 'returns plan status data for type 30' do
          assert_equal(edata.benefitsInformation.select {|bi| bi.dig('serviceTypeCodes')&.include?('30') }.size, edata.benefits(service_code: '30').size)
        end

        describe 'returns empty array' do
          it 'empty data' do
            assert(edata_empty.benefits(service_code: '30').empty?)
          end

          it 'for non matched code' do
            assert(edata.benefits(service_code: 'cat').empty?)
          end
        end
      end

      describe '#active?' do
        it 'true when statusCode is 1' do
          assert(edata.active?)
        end

        describe 'false' do
          it 'non zero codes' do
            assert_equal(false, edata_inactive.active?)
          end

          it 'empty data' do
            assert_equal(false, edata_empty.active?)
          end

          it 'for non matched code' do
            assert_equal(false, edata.active?(service_code: 'cat'))
          end
        end
      end

      describe '#individual_coinsurance' do
        it 'can look up by time qualifier' do
          assert_equal(0.3, edata.individual_coinsurance(service_code: '98', time_qualifier: ChangeHealth::Models::EligibilityData::VISIT))
        end

        it 'is nil if not found' do
          assert_nil(edata.individual_coinsurance(service_code: '98', time_qualifier: 'cat'))
        end

        describe '#individual_coinsurance_visit' do
          it 'equals individual_coinsurance with default time_qualifier' do
            assert_equal(edata.individual_coinsurance(service_code: '98', time_qualifier: ChangeHealth::Models::EligibilityData::VISIT), edata.individual_coinsurance_visit(service_code: '98'))
          end
        end

        describe '#individual_oop_total' do
          it 'equals individual_oop with default time_qualifier' do
            assert_equal(edata.individual_oop(service_code: '30', time_qualifier: ChangeHealth::Models::EligibilityData::YEAR), edata.individual_oop_total(service_code: '30'))
          end
        end
      end

      describe '#individual_copayment' do
        it 'can look up by time qualifier' do
          assert_equal(30.00, edata.individual_copayment(service_code: '98', time_qualifier: ChangeHealth::Models::EligibilityData::VISIT))
        end

        it 'is nil if not found' do
          assert_nil(edata.individual_copayment(service_code: '98', time_qualifier: 'cat'))
        end

        describe '#individual_copayment_visit' do
          it 'equals individual_copayment with default time_qualifier' do
            assert_equal(edata.individual_copayment(service_code: '98', time_qualifier: ChangeHealth::Models::EligibilityData::VISIT), edata.individual_copayment_visit(service_code: '98'))
          end
        end

        describe '#individual_oop_total' do
          it 'equals individual_oop with default time_qualifier' do
            assert_equal(edata.individual_oop(service_code: '30', time_qualifier: ChangeHealth::Models::EligibilityData::YEAR), edata.individual_oop_total(service_code: '30'))
          end
        end
      end

      describe '#individual_oop' do
        it 'can look up by time qualifier' do
          assert_equal(4195.37, edata.individual_oop(service_code: '30', time_qualifier: ChangeHealth::Models::EligibilityData::REMAINING))
          assert_equal(5500.00, edata.individual_oop(service_code: '30', time_qualifier: ChangeHealth::Models::EligibilityData::YEAR))
        end

        it 'is nil if not found' do
          assert_nil(edata.individual_oop(service_code: '30', time_qualifier: 'cat'))
        end

        describe '#individual_oop_remaining' do
          it 'equals individual_oop with default time_qualifier' do
            assert_equal(edata.individual_oop(service_code: '30', time_qualifier: ChangeHealth::Models::EligibilityData::REMAINING), edata.individual_oop_remaining(service_code: '30'))
          end
        end

        describe '#individual_oop_total' do
          it 'equals individual_oop with default time_qualifier' do
            assert_equal(edata.individual_oop(service_code: '30', time_qualifier: ChangeHealth::Models::EligibilityData::YEAR), edata.individual_oop_total(service_code: '30'))
          end
        end
      end
    end
  end
end
