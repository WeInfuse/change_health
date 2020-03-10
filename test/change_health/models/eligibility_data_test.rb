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
      describe '#control_number' do
        it 'accesses controlNumber in hash' do
          assert_equal('401574089', edata.control_number)
          assert_equal(edata.controlNumber, edata.control_number)
        end
      end

      describe 'plan_statuses' do
        it 'aliases planStatus in hash' do
          assert_equal(json_data['planStatus'], edata.plan_statuses)
        end
      end

      describe 'benefits_information' do
        it 'aliases benefitsInformation in hash' do
          assert_equal(json_data['benefitsInformation'], edata.benefits_information)
        end
      end

      describe 'date_info' do
        it 'aliases planDateInformation in hash' do
          assert_equal(json_data['planDateInformation'], edata.date_info)
        end

        describe 'helpers' do
          describe 'no data' do
            it 'digs more dates' do
              assert_nil(edata.eligibility_begin_date)
              assert_nil(edata.plan_begin_date)
              assert_nil(edata.service_date)
            end
          end

          describe 'with data' do
            let(:json_data) { load_sample('000045.example.response.json', parse: true) }
            let(:edata) { ChangeHealth::Models::EligibilityData.new(data: json_data) }

            it 'digs more dates' do
              assert_equal(Date.new(2012, 5, 1), edata.eligibility_begin_date)
              assert_equal(Date.new(2015, 1, 1), edata.plan_begin_date)
              assert_equal(Date.new(2016, 9, 15), edata.service_date)
            end
          end

          describe 'with junky data' do
            let(:edata) { ChangeHealth::Models::EligibilityData.new(data: { 'planDateInformation' => { 'planBegin' => '029183-1283123' } }) }

            it 'digs more dates' do
              assert_equal('029183-1283123', edata.plan_begin_date)
            end
          end
        end
      end

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
        it 'returns all benefits mapped to subclass' do
          assert_equal(edata.benefits_information.size, edata.benefits.size)
        end

        describe 'returns empty array' do
          it 'empty data' do
            assert(edata_empty.benefits.empty?)
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
    end
  end
end
