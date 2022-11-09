require 'test_helper'

class Report835DataTest < Minitest::Test
  describe 'report 835 data' do
    let(:report_name) { 'R5000000.WC' }
    let(:json_data) { load_sample("claim/report/report.#{report_name}.json.response.json", parse: true) }
    let(:report_data) { ChangeHealth::Response::Claim::Report835Data.new(report_name, true, data: json_data) }

    it 'transaction' do
      assert_equal 3, report_data.transactions.size
    end

    it 'payer_identification' do
      assert_equal '06102', report_data.payer_identification
    end

    it 'payer_name' do
      assert_equal 'DENTAL OF ABC', report_data.payer_name
    end

    it 'report_creation_date' do
      assert_equal Date.new(2019, 4, 5), report_data.report_creation_date
    end

    describe 'payments' do
      let(:actual_payment) { report_data.payments[0] }
      it 'count' do
        assert_equal report_data.transactions.size, report_data.payments.count
      end

      it 'payment contents' do
        address = {
          address1: '225 MAIN STREET',
          city: 'CENTERVILLE',
          state: 'PA',
          postalCode: '17111'
        }
        assert_equal Date.new(2019, 3, 31), actual_payment.check_issue_or_eft_effective_date
        assert_equal '12345', actual_payment.check_or_eft_trace_number
        assert_equal '1351840597', actual_payment.payer_identifier
        assert_equal address[:address1], actual_payment.payer_address['address1']
        assert_equal 'DENTAL OF ABC', actual_payment.payer_name
        assert_equal 'CHK', actual_payment.payment_method_code
        assert_equal Date.new(2019, 4, 5), actual_payment.report_creation_date
        assert_equal report_name, actual_payment.report_name
        assert_equal '810.8', actual_payment.total_actual_provider_payment_amount
      end

      it 'payment provider adjustments' do
        assert_equal 1, actual_payment.provider_adjustments.size

        provider_adjustment = actual_payment.provider_adjustments[0]

        assert_equal '1124058920', provider_adjustment.provider_identifier
        assert_equal Date.new(2022, 12, 31), provider_adjustment.fiscal_period_date
        adjustments = [{ amount: '52436.08', identifier: '20211124 XP732039', reason_code: 'WO' },
                       { amount: '-49082.64', identifier: '9802717391', reason_code: 'FB' }]
        assert_equal adjustments, provider_adjustment.adjustments
      end
    end

    describe 'claims' do
      it 'count' do
        assert_equal 4, report_data.payments[0].claims.count
        assert_equal 2, report_data.payments[1].claims.count
        assert_equal 3, report_data.payments[2].claims.count
        assert_equal 9, report_data.claims.count
      end

      describe 'claim contents - everything there, from sandbox' do
        let(:actual_claim) { report_data.payments[0].claims[0] }

        service_adjustments = []
        service_adjustments << ChangeHealth::Response::Claim::Report835ServiceAdjustment.new(
          adjustments: { '45' => '1685.95', '253' => '29.7' },
          claim_adjustment_group_code: 'CO'
        )
        service_adjustments << ChangeHealth::Response::Claim::Report835ServiceAdjustment.new(
          adjustments: { '1' => '57.54', '2' => '371.3' },
          claim_adjustment_group_code: 'PR'
        )

        claim_adjustments = []
        claim_adjustments << ChangeHealth::Response::Claim::Report835ServiceAdjustment.new(
          adjustments: { '23' => '19166.72' },
          claim_adjustment_group_code: 'OA'
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
          claim_adjustments: claim_adjustments,
          claim_payment_remark_codes: ['N520'],
          claim_status_code: '1',
          patient_control_number: '7722337',
          patient_first_name: 'SANDY',
          patient_last_name: 'DOE',
          patient_member_id: 'SJD11112',
          payer_claim_control_number: '119932404007801',
          payer_identification: '06102',
          payer_name: 'DENTAL OF ABC',
          report_creation_date: Date.new(2019, 4, 5),
          report_name: 'R5000000.WC',
          service_date_begin: Date.new(2019, 3, 22),
          service_date_end: Date.new(2019, 3, 26),
          service_lines: service_lines,
          service_provider_npi: '1811901945',
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

        expected_service_line = expected_claim.service_lines[0]

        expected_service_line.each_key do |attribute|
          it attribute.to_s do
            assert_equal expected_service_line[attribute], actual_claim.service_lines[0][attribute]
          end
        end

        expected_service_adjustment = expected_service_line.service_adjustments[0]

        expected_service_adjustment.each_key do |attribute|
          it attribute.to_s do
            assert_equal expected_service_adjustment[attribute],
                         actual_claim.service_lines[0].service_adjustments[0][attribute]
          end
        end
      end

      describe 'claim field oddities' do
        let(:odd_claim1) { report_data.payments[1].claims[0] }
        let(:odd_claim2) { report_data.payments[2].claims[0] }
        let(:odd_claim_service_date) { report_data.payments[2].claims[2] }
        it 'member id' do
          assert_equal 'SJD11122', odd_claim1.patient_member_id
        end

        it 'provider npi from provider info summary' do
          assert_equal '1811901928', odd_claim1.service_provider_npi
        end

        it 'provider npi from payee npi' do
          assert_equal '9999947036', odd_claim2.service_provider_npi
        end

        it 'service line serviceDate missing' do
          assert_equal Date.new(2019, 3, 23), odd_claim_service_date.service_date_begin
          assert_equal Date.new(2019, 3, 24), odd_claim_service_date.service_date_end
        end
      end
    end
  end
end
