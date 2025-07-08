require 'test_helper'

class Report835ServiceLineTest < Minitest::Test
  describe 'line_adjudication_information' do
    let(:service_adjustments) do
      ChangeHealth::Response::Claim::Report835ServiceAdjustment.new(
        adjustments: { '45' => '180.82', '253' => '13.24', '59' => '827.59' },
        claim_adjustment_group_code: 'PR'
      )
    end
    let(:service_adjustments2) do
      ChangeHealth::Response::Claim::Report835ServiceAdjustment.new(
        adjustments: { '2' => '165.52' },
        claim_adjustment_group_code: 'CO'
      )
    end

    let(:claim_information) do
      ChangeHealth::Response::Claim::Report835ServiceLine.new(
        adjudicated_procedure_code: 'J1745',
        allowed_actual: 30_720.0,
        health_care_check_remark_codes: [],
        line_item_charge_amount: 48_000.0,
        line_item_provider_payment_amount: '18432',
        service_adjustments: [service_adjustments, service_adjustments2]
      )
    end

    describe 'multiple adjustments in a group code' do
      let(:expected_answer) do
        [
          {
            adjustmentDetails: [
              { adjustmentReasonCode: '45', adjustmentAmount: '180.82' },
              { adjustmentReasonCode: '253', adjustmentAmount: '13.24' },
              { adjustmentReasonCode: '59', adjustmentAmount: '827.59' }
            ],
            adjustmentGroupCode: 'PR'
          },
          {
            adjustmentDetails: [
              { adjustmentReasonCode: '2', adjustmentAmount: '165.52' }
            ],
            adjustmentGroupCode: 'CO'
          }
        ]
      end

      it 'creates adjustments correctly' do
        actual_result = claim_information.create_adjustment_detail_array

        assert_equal(expected_answer, actual_result)
      end
    end

    it 'Can handle no service adjustments when creating detail array' do
      claim_information.service_adjustments = nil

      assert_empty(claim_information.create_adjustment_detail_array)
    end
  end
end
