require 'test_helper'

class Report835ServiceAdjustmentTest < Minitest::Test
  describe 'report 835 service adjustment' do
    let(:service_adjustment) { ChangeHealth::Response::Claim::Report835ServiceAdjustment.new }

    describe 'adjustments' do
      it 'defaults to no adjustments' do
        assert_nil(service_adjustment.adjustments)
      end

      it 'can add a status_category_code' do
        adjustment = 'pony'
        service_adjustment.add_adjustment(adjustment)
        assert_equal(1, service_adjustment.adjustments.size)
        assert_equal(adjustment, service_adjustment.adjustments.first)
      end
    end
  end
end
