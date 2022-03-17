require 'test_helper'

class ErrorTest < Minitest::Test
  describe 'errors' do
    let(:field_error0) { { 'field' => 'patient.name', 'description' => 'is too short' } }
    let(:field_down) do
      { 'field' => 'Http Header',
        'description' => 'Please review http headers for this API, please contact support if you are unsure how to resolve.' }
    end
    let(:code_needs_fix) { { 'code' => '71', 'description' => 'Need more time' } }
    let(:code_retry_80) do
      { 'code' => '80', 'description' => 'Unable to Respond at Current Time',
        'followupAction' => 'Resubmission Allowed' }
    end
    let(:code_noretry_80) { code_retry_80.merge('followupAction' => 'xxDo Not Resubmitmm;') }
    let(:json_data) { { 'errors' => errors } }

    let(:error_obj) { ChangeHealth::Response::Error.new(error_to_test) }

    describe 'retryable?' do
      describe 'no code' do
        let(:error_to_test) { field_error0 }

        it 'is false' do
          assert_equal(false, error_obj.retryable?)
        end
      end

      describe 'not fixable code' do
        let(:error_to_test) { code_needs_fix }

        it 'is false' do
          assert_equal(false, error_obj.retryable?)
        end
      end

      describe 'fixable code non fixable desc' do
        let(:error_to_test) { code_noretry_80 }

        it 'is false' do
          assert_equal(false, error_obj.retryable?)
        end
      end

      describe 'fixable code' do
        let(:error_to_test) { code_retry_80 }

        it 'is true' do
          assert_equal(true, error_obj.retryable?)
        end
      end

      describe 'down field' do
        let(:error_to_test) { field_down }

        it 'is true' do
          assert_equal(true, error_obj.retryable?)
        end
      end
    end

    describe 'represents_down?' do
      describe 'retryable code' do
        let(:error_to_test) { code_retry_80 }

        it 'is false' do
          assert_equal(false, error_obj.represents_down?)
        end
      end

      describe 'resolvable error' do
        let(:error_to_test) { field_error0 }

        it 'is false' do
          assert_equal(false, error_obj.represents_down?)
        end
      end

      describe 'down field' do
        let(:error_to_test) { field_down }

        it 'is true' do
          assert_equal(true, error_obj.represents_down?)
        end
      end
    end
  end
end
