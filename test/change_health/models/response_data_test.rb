require 'test_helper'

class ResponseDataTest < Minitest::Test

  class FakeData < ChangeHealth::Models::ResponseData
  end

  class FakeResponse
    def initialize(response)
      @response = response
    end

    def parsed_response
      @response.call
    end
  end

  describe 'response data' do
    let(:json_data) { load_sample('health_check.response.json', parse: true) }
    let(:fake_data) { FakeData.new(data: json_data) }
    describe '#initialize' do
      it 'can take data' do
        assert(false == fake_data.nil?)
      end

      it 'can take a response' do
        fake_data = FakeData.new(response: FakeResponse.new(->() { 'hi' }))
        assert(false == fake_data.nil?)
      end

      it 'defaults to empty' do
        fake_data_empty = FakeData.new
        assert(false == fake_data_empty.nil?)
      end

      it 'handles bad response gracefully' do
        fake_data = FakeData.new(response: FakeResponse.new(->() { JSON.parse('bad json') }))
        assert(false == fake_data.nil?)
      end

      it 'does not handle other errors gracefully' do
        assert_raises { FakeData.new(response: FakeResponse.new(->() { nil.say_hi! })) }
      end
    end

    describe 'error handling' do

      describe '#errors?' do
        it 'false if none' do
          assert_equal(false, fake_data.errors?)
        end

        it 'is not recommended retry' do
          assert_equal(false, fake_data.recommend_retry?)
        end

        describe 'with errors' do
          let(:json_data) { load_sample('error_response.fields.json', parse: true) }

          it 'true if errors' do
            assert_equal(true, fake_data.errors?)
          end
        end
      end

      describe 'more complicated errors' do
        let(:field_error0) { {'field' => 'patient.name', 'description' => 'is too short' } }
        let(:field_error1) { {'field' => 'cat', 'description' => 'has meow' } }
        let(:field_down) { {'field' => 'Http Header', 'description' => 'Please review http headers for this API, please contact support if you are unsure how to resolve.'} }
        let(:code_needs_fix) { {'code' => '71', 'description' => 'Need more time' } }
        let(:code_retry_80) { {'code' => '80', 'description' => 'Unable to Respond at Current Time', 'followupAction' => 'Resubmission Allowed'} }
        let(:code_noretry_80) { code_retry_80.merge('followupAction' => 'xxDo Not Resubmitmm;') }
        let(:json_data) { { 'errors' => errors } }

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
            assert_equal(true, fake_data.errors?)
          end

          it 'is not recommended retry' do
            assert_equal(false, fake_data.recommend_retry?)
          end

          it 'has errors' do
            assert_equal(2, fake_data.errors.size)
          end

          it 'has messages from fields' do
            assert_equal("patient.name: is too short", fake_data.errors[0].message)
            assert_equal("cat: has meow", fake_data.errors[1].message)
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
            assert_equal(true, fake_data.errors?)
          end

          it 'is not recommended retry' do
            assert_equal(false, fake_data.recommend_retry?)
          end

          it 'has errors' do
            assert_equal(3, fake_data.errors.size)
          end

          it 'has message' do
            assert_equal('patient.name: is too short', fake_data.errors[0].message)
            assert_equal('71: Need more time', fake_data.errors[1].message)
          end

          it 'code?' do
            assert_equal(false, fake_data.errors[0].code?)
            assert_equal(true, fake_data.errors[1].code?)
          end

          it 'field?' do
            assert_equal(true, fake_data.errors[0].field?)
            assert_equal(false, fake_data.errors[1].field?)
          end
        end

        describe 'recommended retry' do
          describe 'when down' do
            let(:errors) { [field_down] }

            it 'errors? is true' do
              assert_equal(true, fake_data.errors?)
            end

            it 'is recommended retry' do
              assert_equal(true, fake_data.recommend_retry?)
            end
          end

          describe 'when errors' do
            let(:errors) do
              [
                code_retry_80,
                code_retry_80.merge('code' => '42')
              ]
            end

            it 'errors? is true' do
              assert_equal(true, fake_data.errors?)
            end

            it 'is recommended retry' do
              assert_equal(true, fake_data.recommend_retry?)
            end
          end
        end
      end
    end
  end
end

