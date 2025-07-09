require 'test_helper'

class ExtensionsTest < Minitest::Test
  class TestExtensions < ChangeHealth::Response::EligibilityBenefits
    include ChangeHealth::Extensions::InNetworkW
    include ChangeHealth::Extensions::IndividualsAllNonFamily
  end

  describe 'extensions' do
    let(:json_data) do
      [
        {
          inPlanNetworkIndicatorCode: 'Y'
        },
        {
          inPlanNetworkIndicatorCode: 'W',
          coverageLevelCode: 'IND'
        },
        {
          inPlanNetworkIndicatorCode: 'N',
          coverageLevelCode: 'FAM'
        }
      ]
    end
    let(:benefits_default) { ChangeHealth::Response::EligibilityBenefits.new(json_data) }
    let(:benefits) { TestExtensions.new(json_data) }

    describe 'InNetworkW' do
      it 'affects the in_network' do
        assert_equal(2, benefits.in_network.size)
        assert_equal(benefits_default.in_network.size + 1, benefits.in_network.size)
      end
    end

    describe 'InvididualsAllNoneFamily' do
      it 'affects the individuals' do
        assert_equal(2, benefits.individuals.size)
        assert_equal(benefits_default.individuals.size + 1, benefits.individuals.size)
      end
    end
  end
end
