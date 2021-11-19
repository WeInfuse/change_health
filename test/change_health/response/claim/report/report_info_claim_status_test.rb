require 'test_helper'

class ReportInfoClaimStatusTest < Minitest::Test
  describe 'info claim status' do
    let(:info_claim_status) { ChangeHealth::Response::Claim::ReportInfoClaimStatus.new }

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
  end
end
