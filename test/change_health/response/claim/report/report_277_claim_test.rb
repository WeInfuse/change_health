require 'test_helper'

class Report277ClaimTest < Minitest::Test
  describe 'report claim lists' do
    let(:report_claim) { ChangeHealth::Response::Claim::Report277Claim.new }

    describe 'procedure_codes' do
      it 'defaults to no procedure_codes' do
        assert_nil(report_claim.procedure_codes)
      end

      it 'can add a procedure_code' do
        procedure_code = '97161'
        report_claim.add_procedure_code(procedure_code)
        assert_equal(1, report_claim.procedure_codes.size)
        assert_equal(procedure_code, report_claim.procedure_codes.first)
      end
    end

    describe 'info_claim_statuses' do
      it 'defaults to no info_claim_statuses' do
        assert_nil(report_claim.info_claim_statuses)
      end

      it 'can add a status_category_code' do
        info_claim_status = 'A0'
        report_claim.add_info_claim_status(info_claim_status)
        assert_equal(1, report_claim.info_claim_statuses.size)
        assert_equal(info_claim_status, report_claim.info_claim_statuses.first)
      end
    end
  end

  describe 'info_claim_statuses' do
    let(:info_claim_status_old) do
      ChangeHealth::Response::Claim::Report277InfoClaimStatus.new(status_information_effective_date: Date.today - 90)
    end
    let(:info_claim_status_new) do
      ChangeHealth::Response::Claim::Report277InfoClaimStatus.new(status_information_effective_date: Date.today - 2)
    end
    let(:info_claim_status_future) do
      ChangeHealth::Response::Claim::Report277InfoClaimStatus.new(status_information_effective_date: Date.today + 2)
    end

    it 'latest info claim status' do
      report_claim = ChangeHealth::Response::Claim::Report277Claim.new(info_claim_statuses: [info_claim_status_old,
                                                                                             info_claim_status_new,
                                                                                             info_claim_status_future])
      assert_equal info_claim_status_new, report_claim.latest_info_claim_status
    end

    it 'no valid claim status' do
      report_claim = ChangeHealth::Response::Claim::Report277Claim.new(info_claim_statuses: [info_claim_status_future])
      assert_nil report_claim.latest_info_claim_status
    end

    it 'no claim statuses' do
      report_claim = ChangeHealth::Response::Claim::Report277Claim.new
      assert_nil report_claim.latest_info_claim_status
    end

    it 'invalid claim status' do
      info_claim_status_bad = ChangeHealth::Response::Claim::Report277InfoClaimStatus.new(status_information_effective_date: 'not a date!')
      report_claim = ChangeHealth::Response::Claim::Report277Claim.new(info_claim_statuses: [info_claim_status_bad])
      assert_nil report_claim.latest_info_claim_status
    end
  end
end
