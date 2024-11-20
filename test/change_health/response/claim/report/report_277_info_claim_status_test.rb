require 'test_helper'

class Report277InfoClaimStatusTest < Minitest::Test
  describe 'info claim status' do
    let(:info_claim_status) { ChangeHealth::Response::Claim::Report277InfoClaimStatus.new }

    describe 'status_category_codes' do
      it 'defaults to no status_category_codes' do
        assert_nil(info_claim_status.status_category_codes)
      end

      it 'can add a status_category_code' do
        status_category_code = 'A0'
        info_claim_status.add_status_category_code(status_category_code)
        assert_equal(1, info_claim_status.status_category_codes.size)
        assert_equal(status_category_code, info_claim_status.status_category_codes.first)
      end
    end

    describe 'status_code_values' do
      it 'defaults to no status_code_values' do
        assert_nil(info_claim_status.status_code_values)
      end

      it 'can add a status_code_value' do
        status_code_value = 'Claim/line has been paid.'
        info_claim_status.add_status_code_value(status_code_value)
        assert_equal(1, info_claim_status.status_code_values.size)
        assert_equal(status_code_value, info_claim_status.status_code_values.first)
      end
    end
  end
end
