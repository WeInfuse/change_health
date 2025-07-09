require 'test_helper'

class Report277DataTest < Minitest::Test
  describe 'report 277 data' do
    let(:report_name) { 'X3000000.AB' }
    let(:json_data) { load_sample("claim/report/report.#{report_name}.json.response.json", parse: true) }
    let(:report_data) { ChangeHealth::Response::Claim::Report277Data.new(report_name, true, data: json_data) }

    it 'transaction' do
      assert_equal 1, report_data.transactions.size
    end

    it 'payer_name' do
      assert_equal 'PREMERA', report_data.payer_name
    end

    it 'report creation date' do
      assert_equal Date.new(2020, 12, 1), report_data.report_creation_date
    end

    describe 'claims' do
      it 'count' do
        assert_equal 5, report_data.claims.count
      end

      describe 'claim contents - everything there, from sandbox' do
        let(:actual_claim) { report_data.claims.first }
        info_status = ChangeHealth::Response::Claim::Report277InfoStatus.new(
          status_category_code: 'F1',
          status_category_code_value: 'Finalized/Payment-The claim/line has been paid.',
          status_code: '65',
          status_code_value: 'Claim/line has been paid.'
        )
        info_claim_status = ChangeHealth::Response::Claim::Report277InfoClaimStatus.new(
          message: 'BILLING NPI IS NOT AUTHORIZED FOR TAX ID',
          info_statuses: [info_status],
          status_information_effective_date: Date.new(2020, 6, 13),
          total_charge_amount: '100'
        )
        expected_claim = ChangeHealth::Response::Claim::Report277Claim.new(
          clearinghouse_trace_number: '111111111111111',
          id: '2102948947',
          info_claim_statuses: [info_claim_status],
          patient_account_number: '00000',
          patient_first_name: 'JOHNONE',
          patient_last_name: 'DOEONE',
          patient_member_id: '0000000000',
          payer_identification: '430',
          payer_name: 'PREMERA',
          procedure_codes: ['97161'],
          referenced_transaction_trace_number: '000000001',
          report_creation_date: Date.new(2020, 12, 1),
          service_date_begin: Date.new(2020, 2, 14),
          service_date_end: Date.new(2020, 2, 14),
          service_provider_npi: '1111111111',
          trading_partner_claim_number: 'AAAAAAAAAAA1'
        )
        expected_claim.each_key do |attribute|
          it attribute.to_s do
            assert_equal expected_claim[attribute], actual_claim[attribute]
          end
        end

        it 'info_claim_statuses' do
          assert_equal expected_claim.info_claim_statuses.size, actual_claim.info_claim_statuses.size
        end

        expected_info_claim_status = expected_claim.info_claim_statuses.first

        expected_info_claim_status.each_key do |attribute|
          it attribute.to_s do
            assert_equal expected_info_claim_status[attribute], actual_claim.info_claim_statuses.first[attribute]
          end
        end
      end

      describe 'claim contents - missing some fields' do
        let(:short_report_name) { 'X3000000.XX' }
        let(:short_json_data) do
          load_sample("claim/report/report.#{short_report_name}.json.response.json", parse: true)
        end
        let(:short_report_data) do
          ChangeHealth::Response::Claim::Report277Data.new(short_report_name, true, data: short_json_data)
        end
        let(:short_actual_claim) { short_report_data.claims.first }

        info_status = ChangeHealth::Response::Claim::Report277InfoStatus.new(
          status_category_code: 'E1',
          status_category_code_value: 'Response not possible - System Status',
          status_code: '689',
          status_code_value: [
            'Entity was unable to respond within the expected time frame.',
            ' ',
            'Usage: This code requires use of an Entity Code.'
          ].join
        )
        info_claim_status = ChangeHealth::Response::Claim::Report277InfoClaimStatus.new(
          info_statuses: [info_status],
          status_information_effective_date: Date.new(2020, 1, 7),
          total_charge_amount: nil
        )
        expected_claim = ChangeHealth::Response::Claim::Report277Claim.new(
          info_claim_statuses: [info_claim_status],
          patient_first_name: 'johnone',
          patient_last_name: 'doeone',
          payer_name: 'EXTRA HEALTHY INSURANCE',
          procedure_codes: [],
          report_creation_date: Date.new(2020, 1, 7),
          report_name: 'X3000000.XX',
          service_provider_npi: '1760854442'
        )

        it 'claim count' do
          assert_equal 1, short_report_data.claims.count
        end

        expected_claim.each_key do |attribute|
          it attribute.to_s do
            assert_equal expected_claim[attribute], short_actual_claim[attribute]
          end
        end

        %i[service_date_begin service_date_end].each do |attribute|
          it attribute.to_s do
            assert_nil short_actual_claim[attribute]
          end
        end

        it 'info_claim_statuses' do
          assert_equal expected_claim.info_claim_statuses.size, short_actual_claim.info_claim_statuses.size
        end

        expected_info_claim_status = expected_claim.info_claim_statuses.first

        expected_info_claim_status.each_key do |attribute|
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
        let(:complex_json_data) do
          load_sample("claim/report/report.#{complex_report_name}.json.response.json", parse: true)
        end
        let(:complex_report_data) do
          ChangeHealth::Response::Claim::Report277Data.new(complex_report_name, true, data: complex_json_data)
        end

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
