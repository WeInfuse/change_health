require 'test_helper'

class Report277DataTest < Minitest::Test
  describe 'report 277 data' do
    let(:report_name) { 'X3000000.AB' }
    let(:json_data) { load_sample("claim/report/report.#{report_name}.json.response.json", parse: true) }
    let(:report_data) { ChangeHealth::Response::Claim::Report277Data.new(report_name, true, data: json_data) }

    it 'transaction' do
      assert_equal 1, report_data.transactions.size
    end

    it 'payer_org_name' do
      assert_equal 'PREMERA', report_data.payer_org_name
    end

    describe 'claims' do
      it 'count' do
        assert_equal 5, report_data.claims.count
      end

      describe 'claim contents - everything there, from sandbox' do
        let(:actual_claim) { report_data.claims.first }
        info_claim_status = ChangeHealth::Response::Claim::ReportInfoClaimStatus.new(
          status_category_codes: ['F1'],
          total_charge_amount: '100',
          status_information_effective_date: Date.new(2020, 6, 13)
        )
        expected_claim = ChangeHealth::Response::Claim::ReportClaim.new(
          transaction_set_creation_date: Date.new(2020, 12, 1),
          payer_org_name: 'PREMERA',
          service_provider_npi: '1111111111',
          subscriber_first_name: 'JOHNONE',
          subscriber_last_name: 'DOEONE',
          procedure_codes: ['97161'],
          service_begin_date: Date.new(2020, 2, 14),
          service_end_date: Date.new(2020, 2, 14),
          info_claim_statuses: [info_claim_status]
        )
        expected_claim.keys.each do |attribute|
          it attribute.to_s do
            assert_equal expected_claim[attribute], actual_claim[attribute]
          end
        end

        it 'info_claim_statuses' do
          assert_equal expected_claim.info_claim_statuses.size, actual_claim.info_claim_statuses.size
        end

        expected_info_claim_status = expected_claim.info_claim_statuses.first

        expected_info_claim_status.keys.each do |attribute|
          it attribute.to_s do
            assert_equal expected_info_claim_status[attribute], actual_claim.info_claim_statuses.first[attribute]
          end
        end
      end

      describe 'claim contents - missing some fields' do
        let(:short_report_name) { 'X3000000.XX' }
        let(:short_json_data) { load_sample("claim/report/report.#{short_report_name}.json.response.json", parse: true) }
        let(:short_report_data) { ChangeHealth::Response::Claim::Report277Data.new(short_report_name, true, data: short_json_data) }
        let(:short_actual_claim) { short_report_data.claims.first }

        info_claim_status = ChangeHealth::Response::Claim::ReportInfoClaimStatus.new(
          status_category_codes: ['E1'],
          total_charge_amount: nil,
          status_information_effective_date: Date.new(2020, 1, 7)
        )
        expected_claim = ChangeHealth::Response::Claim::ReportClaim.new(
          transaction_set_creation_date: Date.new(2020, 1, 7),
          payer_org_name: 'EXTRA HEALTHY INSURANCE',
          service_provider_npi: '1760854442',
          subscriber_first_name: 'johnone',
          subscriber_last_name: 'doeone',
          procedure_codes: [],
          info_claim_statuses: [info_claim_status]
        )
        it 'claim count' do
          assert_equal 1, short_report_data.claims.count
        end

        expected_claim.keys.each do |attribute|
          it attribute.to_s do
            assert_equal expected_claim[attribute], short_actual_claim[attribute]
          end
        end

        %i[service_begin_date service_end_date].each do |attribute|
          it attribute.to_s do
            assert_nil short_actual_claim[attribute]
          end
        end

        it 'info_claim_statuses' do
          assert_equal expected_claim.info_claim_statuses.size, short_actual_claim.info_claim_statuses.size
        end

        expected_info_claim_status = expected_claim.info_claim_statuses.first

        expected_info_claim_status.keys.each do |attribute|
          it attribute.to_s do
            assert_equal expected_info_claim_status[attribute], short_actual_claim.info_claim_statuses.first[attribute]
          end
        end

        it 'total_charge_amount' do
          assert_nil short_actual_claim.info_claim_statuses.first.total_charge_amount
        end
      end

      describe 'complex 277 claims' do
        let(:complex_report_name) { 'X3000000.JE' }
        let(:complex_json_data) { load_sample("claim/report/report.#{complex_report_name}.json.response.json", parse: true) }
        let(:complex_report_data) { ChangeHealth::Response::Claim::Report277Data.new(complex_report_name, true, data: complex_json_data) }

        it 'number of claims' do
          assert_equal 2, complex_report_data.claims.count
        end

        it 'procedure codes' do
          assert_equal %w[97161 97110], complex_report_data.claims[0].procedure_codes
          assert_equal %w[96365 96416], complex_report_data.claims[1].procedure_codes
        end

        it 'status category codes' do
          assert_equal %w[F1 F2 F1], complex_report_data.claims[0].latest_status_category_codes
          assert_equal %w[A6 A7 D0], complex_report_data.claims[1].latest_status_category_codes
        end
      end
    end
  end
end
