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

      it 'can add an info_claim_status' do
        info_claim_status = ChangeHealth::Response::Claim::Report277InfoClaimStatus.new
        report_claim.add_info_claim_status(info_claim_status)
        assert_equal(1, report_claim.info_claim_statuses.size)
        assert_equal(info_claim_status, report_claim.info_claim_statuses.first)
      end
    end
  end

  describe 'info_claim_statuses' do
    let(:info_status_one) do
      ChangeHealth::Response::Claim::Report277InfoStatus.new(status_category_code: 'F1')
    end
    let(:info_status_two) do
      ChangeHealth::Response::Claim::Report277InfoStatus.new(status_category_code: 'A2')
    end

    let(:info_claim_status_old) do
      ChangeHealth::Response::Claim::Report277InfoClaimStatus.new(
        status_information_effective_date: Date.today - 90,
        info_statuses: [info_status_one]
      )
    end
    let(:info_claim_status_new) do
      ChangeHealth::Response::Claim::Report277InfoClaimStatus.new(
        status_information_effective_date: Date.today - 2,
        info_statuses: [info_status_one, info_status_two]
      )
    end
    let(:info_claim_status_future) do
      ChangeHealth::Response::Claim::Report277InfoClaimStatus.new(
        status_information_effective_date: Date.today + 2,
        info_statuses: [info_status_two]
      )
    end

    let(:multi_status_report_claim) do
      ChangeHealth::Response::Claim::Report277Claim.new(
        info_claim_statuses: [
          info_claim_status_old,
          info_claim_status_new,
          info_claim_status_future
        ]
      )
    end

    it 'latest info claim status' do
      assert_equal info_claim_status_new, multi_status_report_claim.latest_info_claim_status
    end

    it 'latest info statuses' do
      assert_equal info_claim_status_new.info_statuses, multi_status_report_claim.latest_info_statuses
    end

    it 'latest status category codes' do
      assert_equal info_claim_status_new.info_statuses.map(&:status_category_code), multi_status_report_claim.latest_status_category_codes
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
