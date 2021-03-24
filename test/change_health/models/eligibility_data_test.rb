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

  class ChangeHealth::Models::EligibilityBenefitsABC123 < ChangeHealth::Models::EligibilityBenefits
  end

  class ChangeHealth::Models::EligibilityBenefitsCBA987 < ChangeHealth::Models::EligibilityBenefits
    class ChangeHealth::Models::EligibilityBenefitsCBA987_Plan123 < ChangeHealth::Models::EligibilityBenefits
    end

    def self.factory(data)
      if data.plan?('Plan123')
        return ChangeHealth::Models::EligibilityBenefitsCBA987_Plan123
      else
        return self
      end
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

            it 'digs more dates' do
              assert_equal(Date.new(2012, 5, 1), edata.eligibility_begin_date)
              assert_equal(Date.new(2015, 1, 1), edata.plan_begin_date)
              assert_equal(Date.new(2016, 9, 15), edata.service_date)
            end
          end

          describe 'with junky dates' do
            let(:edata) { ChangeHealth::Models::EligibilityData.new(data: { 'planDateInformation' => { 'planBegin' => '029183-1283123' } }) }

            it 'leaves it alone' do
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
          let(:edata) { ChangeHealth::Models::EligibilityData.new }

          it 'is false' do
            assert_equal(false, edata.medicare?)
          end
        end

        describe 'all benefits are medicare' do
          let(:json_data) {
            str = <<-STR
            {
              "benefitsInformation": [
                {
                  "benefitsDateInformation": {
                    "plan": "20041001"
                  },
                  "code": #{ChangeHealth::Models::EligibilityData::ACTIVE},
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
          }

          it 'is true' do
            assert_equal(true, edata.medicare?)
          end
        end
      end

      describe '#benefits' do
        it 'returns all benefits mapped to subclass' do
          assert_equal(edata.benefits_information.size, edata.benefits.size)
          assert_equal(ChangeHealth::Models::EligibilityBenefits, edata.benefits.class)
        end

        describe 'specific class exists for trading partner service id' do
          let(:tpsi) { 'abc123' }
          let(:altered_data) { d = load_sample('000050.example.response.json', parse: true); d['tradingPartnerServiceId'] = tpsi; d }
          let(:json_data) { altered_data }

          it 'instantiates that class' do
            assert_equal(edata.benefits_information.size, edata.benefits.size)
            assert_equal(ChangeHealth::Models::EligibilityBenefitsABC123, edata.benefits.class)
          end

          describe 'responds to #factory' do
            let(:tpsi) { 'cba987' }

            it 'instantiates the returned class' do
              assert_equal(edata.benefits_information.size, edata.benefits.size)
              assert_equal(ChangeHealth::Models::EligibilityBenefitsCBA987, edata.benefits.class)
            end

            describe 'can use data object to select' do
              let(:json_data) { altered_data['planStatus'][0]['planDetails'] = 'Plan123'; altered_data }

              it 'instantiates the returned class' do
                assert_equal(edata.benefits_information.size, edata.benefits.size)
                assert_equal(ChangeHealth::Models::EligibilityBenefitsCBA987_Plan123, edata.benefits.class)
              end
            end
          end
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

        describe 'no service codes' do
          let(:altered_data) {
            d = load_sample('000050.example.response.json', parse: true);
            d['planStatus'] = altered_plan_status
            d
          }
          let(:json_data) { altered_data }

          describe 'no other codes' do
            let(:altered_plan_status) {
              [
                {"statusCode" => ChangeHealth::Models::EligibilityData::ACTIVE,"status" => "Active Coverage","planDetails" => "OTHER"}
              ]
            }

            it 'is false' do
              assert_equal(false, edata.active?)
            end
          end

          describe 'other active code' do
            let(:altered_plan_status) {
              [
                {"statusCode" => ChangeHealth::Models::EligibilityData::ACTIVE,"status" => "Active Coverage","planDetails" => "OTHER"},
                {"statusCode" => ChangeHealth::Models::EligibilityData::ACTIVE,"status" => "Active Coverage","planDetails" => "BASIC", "serviceTypeCodes" => [ "30" ]}
              ]
            }

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
          let(:altered_data) {
            d = load_sample('000050.example.response.json', parse: true);
            d['planStatus'] = altered_plan_status
            d
          }
          let(:json_data) { altered_data }

          describe 'no other codes' do
            let(:altered_plan_status) {
              [
                {"statusCode" => ChangeHealth::Models::EligibilityData::INACTIVE,"status" => "Active Coverage","planDetails" => "OTHER"}
              ]
            }

            it 'is false' do
              assert_equal(false, edata.inactive?)
            end
          end

          describe 'other active code' do
            let(:altered_plan_status) {
              [
                {"statusCode" => ChangeHealth::Models::EligibilityData::INACTIVE,"status" => "Active Coverage","planDetails" => "OTHER"},
                {"statusCode" => ChangeHealth::Models::EligibilityData::ACTIVE,"status" => "Active Coverage","planDetails" => "BASIC", "serviceTypeCodes" => [ "30" ]},
                {"statusCode" => ChangeHealth::Models::EligibilityData::INACTIVE,"status" => "Active Coverage","planDetails" => "BASIC", "serviceTypeCodes" => [ "30" ]}
              ]
            }

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

      describe 'error handling' do
        describe '#errors?' do
          it 'false if none' do
            assert_equal(false, edata.errors?)
          end

          it 'is not recommended retry' do
            assert_equal(false, edata.recommend_retry?)
          end

          describe 'with errors' do
            let(:json_data) { load_sample('error_response.fields.json', parse: true) }

            it 'true if errors' do
              assert_equal(true, edata.errors?)
            end
          end
        end

        describe 'more complicated errors' do
          let(:field_error0) { {'field' => 'patient.name', 'description' => 'is too short' } }
          let(:field_error1) { {'field' => 'cat', 'description' => 'has meow' } }
          let(:code_needs_fix) { {'code' => '71', 'description' => 'Need more time' } }
          let(:code_retry_80) { {'code' => '80', 'description' => 'Unable to Respond at Current Time', 'followupAction' => 'blah'} }
          let(:code_noretry_80) { code_retry_80.merge('followupAction' => 'xxDo Not Resubmitmm;') }
          let(:json_data) { { 'errors' => errors } }

          describe 'retryable?' do
            let(:error_obj) { ChangeHealth::Models::Error.new(eut) }

            describe 'no code' do
              let(:eut) { field_error0 }

              it 'is false' do
                assert_equal(false, error_obj.retryable?)
              end
            end

            describe 'not fixable code' do
              let(:eut) { code_needs_fix }

              it 'is false' do
                assert_equal(false, error_obj.retryable?)
              end
            end

            describe 'fixable code non fixable desc' do
              let(:eut) { code_noretry_80 }

              it 'is false' do
                assert_equal(false, error_obj.retryable?)
              end
            end

            describe 'fixable code' do
              let(:eut) { code_retry_80 }

              it 'is true' do
                assert_equal(true, error_obj.retryable?)
              end
            end
          end

          describe 'multiple errors' do
            let(:errors) do
              [
                [
                  field_error0
                ],
                [
                  field_error1
                ]
              ]
            end

            it 'errors? is true' do
              assert_equal(true, edata.errors?)
            end

            it 'is not recommended retry' do
              assert_equal(false, edata.recommend_retry?)
            end

            it 'has errors' do
              assert_equal(2, edata.errors.size)
            end

            it 'has messages from fields' do
              assert_equal("patient.name: is too short", edata.errors[0].message)
              assert_equal("cat: has meow", edata.errors[1].message)
            end
          end

          describe 'error codes' do
            let(:errors) do
              [
                field_error0,
                code_needs_fix,
                code_noretry_80
              ]
            end

            it 'errors? is true' do
              assert_equal(true, edata.errors?)
            end

            it 'is not recommended retry' do
              assert_equal(false, edata.recommend_retry?)
            end

            it 'has errors' do
              assert_equal(3, edata.errors.size)
            end

            it 'has message' do
              assert_equal('patient.name: is too short', edata.errors[0].message)
              assert_equal('71: Need more time', edata.errors[1].message)
            end

            it 'code?' do
              assert_equal(false, edata.errors[0].code?)
              assert_equal(true, edata.errors[1].code?)
            end

            it 'field?' do
              assert_equal(true, edata.errors[0].field?)
              assert_equal(false, edata.errors[1].field?)
            end
          end

          describe 'recommended retry' do
            let(:errors) do
              [
                code_retry_80,
                code_retry_80.merge('code' => '42')
              ]
            end

            it 'errors? is true' do
              assert_equal(true, edata.errors?)
            end

            it 'is recommended retry' do
              assert_equal(true, edata.recommend_retry?)
            end
          end
        end
      end

      describe '#trading_partner_id' do
        it 'gets the partner service id' do
          assert_equal('000050', edata.trading_partner_id)
        end
      end

      describe '#trading_partner?' do
        it 'returns whether trading_partner matche trading_partner_id' do
          assert_equal(true, edata.trading_partner?('000050'))
          assert_equal(false, edata.trading_partner?('cat'))
        end
      end
    end
  end
end
