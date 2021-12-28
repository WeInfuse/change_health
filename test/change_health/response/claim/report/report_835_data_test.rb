require 'test_helper'

class Report835DataTest < Minitest::Test
  describe 'report 835 data' do
    let(:report_name) { 'R5000000.WC' }
    let(:json_data) { load_sample("claim/report/report.#{report_name}.json.response.json", parse: true) }
    let(:report_data) { ChangeHealth::Response::Claim::Report835Data.new(report_name, true, data: json_data) }

    it 'transaction' do
      assert_equal 1, report_data.transactions.size
    end

    it 'payer_name' do
      assert_equal 'DENTAL OF ABC', report_data.payer_name
    end

    it 'payment_method_code' do
      assert_equal 'CHK', report_data.payment_method_code
    end

    it 'report_creation_date' do
      assert_equal Date.new(2019, 4, 5), report_data.report_creation_date
    end

    it 'total_actual_provider_payment_amount' do
      assert_equal '810.8', report_data.total_actual_provider_payment_amount
    end

    describe 'claims' do
      it 'count' do
        assert_equal 9, report_data.claims.count
      end

      describe 'claim contents - everything there, from sandbox' do
        let(:actual_claim) { report_data.claims.first }
        service_adjustments = []
        service_adjustments << ChangeHealth::Response::Claim::Report835ServiceAdjustment.new(
          adjustments: { '45' => '1685.95', '253' => '29.7' },
          claim_adjustment_group_code: 'CO'
        )
        service_adjustments << ChangeHealth::Response::Claim::Report835ServiceAdjustment.new(
          adjustments: { '1' => '57.54', '2' => '371.3' },
          claim_adjustment_group_code: 'PR'
        )

        health_care_check_remark_codes = [ChangeHealth::Response::Claim::Report835HealthCareCheckRemarkCode.new(
          code_list_qualifier_code: 'HE',
          code_list_qualifier_code_value: 'Claim Payment Remark Codes',
          remark_code: 'N510'
        )]

        service_lines = []
        service_lines << ChangeHealth::Response::Claim::Report835ServiceLine.new(
          adjudicated_procedure_code: 'D0120',
          allowed_actual: '25',
          line_item_charge_amount: '46',
          line_item_provider_payment_amount: '25',
          service_adjustments: service_adjustments,
          health_care_check_remark_codes: health_care_check_remark_codes
        )
        service_lines += [1, 2, 3, 4]

        expected_claim = ChangeHealth::Response::Claim::Report835Claim.new(
          claim_payment_remark_codes: ['N520'],
          patient_first_name: 'SANDY',
          patient_last_name: 'DOE',
          payer_claim_control_number: '119932404007801',
          payer_identification: '06102',
          payer_name: 'DENTAL OF ABC',
          payment_method_code: 'CHK',
          report_creation_date: Date.new(2019, 4, 5),
          service_date_begin: Date.new(2019, 3, 22),
          service_date_end: Date.new(2019, 3, 26),
          service_lines: service_lines,
          service_provider_npi: '1811901945',
          total_actual_provider_payment_amount: '810.8',
          total_charge_amount: '226'
        )
        expected_claim.each_key do |attribute|
          next if attribute == :service_lines

          it attribute.to_s do
            assert_equal expected_claim[attribute], actual_claim[attribute]
          end
        end

        it 'procedure_codes' do
          assert_equal %w[D0120 D0220 D0230 D0274 D1110], actual_claim.procedure_codes
        end

        it 'number of service_lines' do
          assert_equal expected_claim.service_lines.size, actual_claim.service_lines.size
        end

        expected_service_line = expected_claim.service_lines.first

        expected_service_line.each_key do |attribute|
          it attribute.to_s do
            assert_equal expected_service_line[attribute], actual_claim.service_lines.first[attribute]
          end
        end

        expected_service_adjustment = expected_service_line.service_adjustments.first

        expected_service_adjustment.each_key do |attribute|
          it attribute.to_s do
            assert_equal expected_service_adjustment[attribute],
                         actual_claim.service_lines.first.service_adjustments.first[attribute]
          end
        end
      end
    end
  end
end
