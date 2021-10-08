require 'test_helper'

class SubmissionDataTest < Minitest::Test

  describe 'submission data' do
    let(:json_data) { load_sample('claim/submission/success.example.response.json', parse: true) }
    let(:submission_data) { ChangeHealth::Response::Claim::SubmissionData.new(data: json_data) }

    describe 'object' do

      describe 'trading partner' do
        it 'gets the trading partner id' do
          assert_equal('RANDOM_ID', submission_data.trading_partner_id)
        end

        it 'get the trading partner service id' do
          assert_equal('9496', submission_data.trading_partner_service_id)
        end

        it 'returns whether trading_partner matches trading_partner_id or trading_partner_service_id' do
          assert_equal(true, submission_data.trading_partner?('RANDOM_ID'))
          assert_equal(true, submission_data.trading_partner?('9496'))
          assert_equal(false, submission_data.trading_partner?('cat'))
        end
      end

      describe '#control_number' do
        it 'accesses controlNumber in hash' do
          assert_equal('000000001', submission_data.control_number)
          assert_equal(submission_data.controlNumber, submission_data.control_number)
        end
      end

      describe 'status' do
        it 'aliases status in hash' do
          assert_equal(json_data['status'], submission_data.status)
        end
      end
    end
  end
end
