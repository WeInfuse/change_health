require 'test_helper'

class Report277InfoClaimStatusTest < Minitest::Test
  describe 'info claim status' do
    let(:info_claim_status) { ChangeHealth::Response::Claim::Report277InfoClaimStatus.new }
    let(:info_status) { ChangeHealth::Response::Claim::Report277InfoStatus.new }

    describe 'info_statuses' do
      it 'defaults to no info_statuses' do
        assert_nil(info_claim_status.info_statuses)
      end

      it 'can add an info_status' do
        info_claim_status.add_info_status(info_status)

        assert_equal(1, info_claim_status.info_statuses.size)
        assert_equal(info_status, info_claim_status.info_statuses.first)
      end
    end
  end
end
