require 'test_helper'

class EligibilityDataTest < Minitest::Test
  class ChangeHealth::Response::EligibilityBenefitsABC123 < ChangeHealth::Response::EligibilityBenefits
  end

  # rubocop:disable Naming/ClassAndModuleCamelCase
  class ChangeHealth::Response::EligibilityBenefitsCBA987 < ChangeHealth::Response::EligibilityBenefits
    class ChangeHealth::Response::EligibilityBenefitsCBA987_Plan123 < ChangeHealth::Response::EligibilityBenefits
    end

    def self.factory(data)
      return ChangeHealth::Response::EligibilityBenefitsCBA987_Plan123 if data.plan?('Plan123')

      self
    end
  end
  # rubocop:enable Naming/ClassAndModuleCamelCase

  describe 'eligibility data' do
    let(:json_data) { load_sample('000050.example.response.json', parse: true) }
    let(:edata) { ChangeHealth::Response::EligibilityData.new(data: json_data) }
    let(:edata_empty) { ChangeHealth::Response::EligibilityData.new }
    let(:edata_inactive) { ChangeHealth::Response::EligibilityData.new(data: load_sample('000041.example.response.json', parse: true)) }

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

            it 'digs more dates' do
              assert_equal(Date.new(2012, 5, 1), edata.eligibility_begin_date)
              assert_equal(Date.new(2015, 1, 1), edata.plan_begin_date)
              assert_equal(Date.new(2016, 9, 15), edata.service_date)
            end
          end

          describe 'with junky dates' do
            let(:edata) { ChangeHealth::Response::EligibilityData.new(data: { 'planDateInformation' => { 'planBegin' => '029183-1283123' } }) }

            it 'leaves it alone' do
              assert_equal('029183-1283123', edata.plan_begin_date)
            end
          end
        end
      end

      describe '#plan_status' do
        it 'returns plan status data' do
          assert_equal(edata.planStatus.first.keys.size, edata.plan_status(service_code: '30').keys.size)
        end

        describe 'returns empty hash' do
          it 'empty data' do
            assert_empty(edata_empty.plan_status(service_code: '30'))
          end

          it 'for non matched code' do
            assert_empty(edata.plan_status(service_code: 'cat'))
          end
        end

        describe 'single flag' do
          describe 'false' do
            before do
              edata.planStatus << edata.planStatus.first.dup
            end

            it 'returns all matching statuses' do
              assert_equal(2, edata.plan_status(service_code: '30', single: false).size)
            end
          end
        end
      end

      describe '#medicare?' do
        describe 'all benefits are not medicare' do
          it 'is false' do
            assert_equal(false, edata.medicare?)
          end
        end

        describe 'benefits are empty' do
          let(:edata) { ChangeHealth::Response::EligibilityData.new }

          it 'is false' do
            assert_equal(false, edata.medicare?)
          end
        end

        describe 'all benefits are medicare' do
          let(:json_data) do
            str = <<-STR
            {
              "benefitsInformation": [
                {
                  "benefitsDateInformation": {
                    "plan": "20041001"
                  },
                  "code": #{ChangeHealth::Response::EligibilityData::ACTIVE},
                  "insuranceType": "Medicare Part A",
                  "insuranceTypeCode": "MA",
                  "name": "Active Coverage",
                  "serviceTypeCodes": [
                    "30"
                  ],
                  "serviceTypes": [
                    "Health Benefit Plan Coverage"
                  ]
                }
              ]
            }
            STR
            JSON.parse(str)
          end

          it 'is true' do
            assert_equal(true, edata.medicare?)
          end
        end
      end

      describe '#benefits' do
        it 'returns all benefits mapped to subclass' do
          assert_equal(edata.benefits_information.size, edata.benefits.size)
          assert_instance_of(ChangeHealth::Response::EligibilityBenefits, edata.benefits)
        end

        describe 'specific class exists for trading partner service id' do
          let(:tpsi) { 'abc123' }
          let(:altered_data) do
            d = load_sample('000050.example.response.json', parse: true)
            d['tradingPartnerServiceId'] = tpsi
            d
          end
          let(:json_data) { altered_data }

          it 'instantiates that class' do
            assert_equal(edata.benefits_information.size, edata.benefits.size)
            assert_instance_of(ChangeHealth::Response::EligibilityBenefitsABC123, edata.benefits)
          end

          describe 'responds to #factory' do
            let(:tpsi) { 'cba987' }

            it 'instantiates the returned class' do
              assert_equal(edata.benefits_information.size, edata.benefits.size)
              assert_instance_of(ChangeHealth::Response::EligibilityBenefitsCBA987, edata.benefits)
            end

            describe 'can use data object to select' do
              let(:json_data) do
                altered_data['planStatus'][0]['planDetails'] = 'Plan123'
                altered_data
              end

              it 'instantiates the returned class' do
                assert_equal(edata.benefits_information.size, edata.benefits.size)
                assert_instance_of(ChangeHealth::Response::EligibilityBenefitsCBA987_Plan123, edata.benefits)
              end
            end
          end
        end

        describe 'returns empty array' do
          it 'empty data' do
            assert_empty(edata_empty.benefits)
          end
        end
      end

      describe '#active?' do
        it 'true when statusCode is 1' do
          assert_predicate(edata, :active?)
        end

        describe 'no service codes' do
          let(:altered_data) do
            d = load_sample('000050.example.response.json', parse: true)
            d['planStatus'] = altered_plan_status
            d
          end
          let(:json_data) { altered_data }

          describe 'no other codes' do
            let(:altered_plan_status) do
              [
                { 'statusCode' => ChangeHealth::Response::EligibilityData::ACTIVE, 'status' => 'Active Coverage', 'planDetails' => 'OTHER' }
              ]
            end

            it 'is false' do
              assert_equal(false, edata.active?)
            end
          end

          describe 'other active code' do
            let(:altered_plan_status) do
              [
                { 'statusCode' => ChangeHealth::Response::EligibilityData::ACTIVE, 'status' => 'Active Coverage',
                  'planDetails' => 'OTHER' },
                { 'statusCode' => ChangeHealth::Response::EligibilityData::ACTIVE, 'status' => 'Active Coverage', 'planDetails' => 'BASIC', 'serviceTypeCodes' => ['30'] }
              ]
            end

            it 'is true' do
              assert_equal(true, edata.active?)
            end
          end
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

      describe '#inactive?' do
        it 'false if status not 6' do
          assert_equal(false, edata.inactive?)
        end

        describe 'no service codes' do
          let(:altered_data) do
            d = load_sample('000050.example.response.json', parse: true)
            d['planStatus'] = altered_plan_status
            d
          end
          let(:json_data) { altered_data }

          describe 'no other codes' do
            let(:altered_plan_status) do
              [
                { 'statusCode' => ChangeHealth::Response::EligibilityData::INACTIVE, 'status' => 'Active Coverage', 'planDetails' => 'OTHER' }
              ]
            end

            it 'is false' do
              assert_equal(false, edata.inactive?)
            end
          end

          describe 'other active code' do
            let(:altered_plan_status) do
              [
                { 'statusCode' => ChangeHealth::Response::EligibilityData::INACTIVE, 'status' => 'Active Coverage',
                  'planDetails' => 'OTHER' },
                { 'statusCode' => ChangeHealth::Response::EligibilityData::ACTIVE, 'status' => 'Active Coverage',
                  'planDetails' => 'BASIC', 'serviceTypeCodes' => ['30'] },
                { 'statusCode' => ChangeHealth::Response::EligibilityData::INACTIVE, 'status' => 'Active Coverage', 'planDetails' => 'BASIC', 'serviceTypeCodes' => ['30'] }
              ]
            end

            it 'is true' do
              assert_equal(true, edata.inactive?)
            end
          end
        end

        describe 'false' do
          it 'non zero codes' do
            assert_equal(true, edata_inactive.inactive?)
          end

          it 'empty data' do
            assert_equal(false, edata_empty.inactive?)
          end

          it 'for non matched code' do
            assert_equal(false, edata.inactive?(service_code: 'cat'))
          end
        end
      end

      describe '#trading_partner_id' do
        it 'gets the partner service id' do
          assert_equal('000050', edata.trading_partner_id)
        end
      end

      describe '#trading_partner?' do
        it 'returns whether trading_partner matches trading_partner_id' do
          assert_equal(true, edata.trading_partner?('000050'))
          assert_equal(false, edata.trading_partner?('cat'))
        end
      end
    end
  end
end
