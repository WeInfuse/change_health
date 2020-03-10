require 'test_helper'

class EligibilityBenefitTest < Minitest::Test
  describe 'eligibility data' do
    let(:json_data) { load_sample('000050.example.response.json', parse: true) }
    let(:edata) { ChangeHealth::Models::EligibilityData.new(data: json_data) }
    let(:benefits) { edata.benefits }
    let(:benefit) { benefits.first }
    let(:klazz) { ChangeHealth::Models::EligibilityBenefit }

    describe 'benefit' do
      it '#individual?' do
        assert(klazz.new(coverageLevelCode: klazz::INDIVIDUAL).individual?)
        assert_equal(false, klazz.new(coverageLevelCode: klazz::CHILD).individual?)
        assert_equal(false, klazz.new.individual?)
      end

      it '#child?' do
        assert(klazz.new(coverageLevelCode: klazz::CHILD).child?)
        assert_equal(false, klazz.new(coverageLevelCode: klazz::INDIVIDUAL).child?)
        assert_equal(false, klazz.new.child?)
      end

      it '#visit?' do
        assert(klazz.new(timeQualifierCode: klazz::VISIT).visit?)
        assert_equal(false, klazz.new.visit?)
      end

      it '#remaining?' do
        assert(klazz.new(timeQualifierCode: klazz::REMAINING).remaining?)
        assert_equal(false, klazz.new.remaining?)
      end

      it '#year?' do
        assert(klazz.new(timeQualifierCode: klazz::YEAR).year?)
        assert_equal(false, klazz.new.year?)
      end

      it '#copayment?' do
        assert(klazz.new(code: klazz::COPAYMENT).copayment?)
        assert_equal(false, klazz.new.copayment?)
      end

      it '#coinsurance?' do
        assert(klazz.new(code: klazz::COINSURANCE).coinsurance?)
        assert_equal(false, klazz.new.coinsurance?)
      end

      it '#non_covered?' do
        assert(klazz.new(code: klazz::NON_COVERED).non_covered?)
        assert_equal(false, klazz.new.non_covered?)
      end

      it '#out_of_pocket?' do
        assert(klazz.new(code: klazz::OUT_OF_POCKET).out_of_pocket?)
        assert_equal(false, klazz.new.out_of_pocket?)
      end

      it '#in_plan_network?' do
        assert(klazz.new(inPlanNetworkIndicatorCode: 'Y').in_plan_network?)
        assert(klazz.new(inPlanNetworkIndicatorCode: 'Y').in_plan?)
        assert(klazz.new(inPlanNetworkIndicatorCode: 'Y').in_network?)
        assert_equal(false, klazz.new.in_plan_network?)
      end

      describe '#services' do
        it 'returns readable service type and code' do
          assert_equal([['98', 'Professional (Physician) Visit - Office']], klazz.new(serviceTypeCodes: ['98'], serviceTypes: ['Professional (Physician) Visit - Office']).services)
        end

        it 'handles no type descriptor' do
          assert_equal([['98', nil]], klazz.new(serviceTypeCodes: ['98']).services)
        end

        it 'handles no type codes' do
          assert_equal([], klazz.new(serviceTypes: ['cat']).services)
        end

        it 'handles no types' do
          assert_equal([], klazz.new.services)
        end
      end

      describe '#amount' do
        it 'returns benefitPercent on coinsurance' do
          benefit = klazz.new(code: klazz::COINSURANCE, benefitPercent: '.3', benefitAmount: '43.23')

          assert_equal(0.3, benefit.amount)
        end

        it 'returns benefitAmount othewise' do
          benefit = klazz.new(code: klazz::COPAYMENT, benefitPercent: '.3', benefitAmount: '43.23')

          assert_equal(43.23, benefit.amount)
        end

        it 'can return nil if amounts non-existent' do
          assert_nil(klazz.new.amount)
        end
      end
    end

    describe 'benefits' do
      describe '#where' do
        it 'filters results' do
          assert_equal(3, benefits.where(serviceTypeCodes: '30', coverageLevelCode: 'IND').size)
          assert_equal(1, benefits.where(serviceTypeCodes: '30', coverageLevelCode: 'IND', timeQualifierCode: ChangeHealth::Models::EligibilityBenefit::REMAINING).size)
        end

        describe 'benefit key is an array' do
          it 'handles values' do
            assert_equal(3, benefits.where(serviceTypeCodes: '30').size)
          end

          it 'handles arrays' do
            assert_equal(5, benefits.where(serviceTypeCodes: ['30', 'BZ']).size)
          end
        end

        describe 'benefit key is a value' do
          it 'handles values' do
            assert_equal(1, benefits.where(inPlanNetworkIndicatorCode: 'N').size)
          end

          it 'can handle arrays' do
            assert_equal(7, benefits.where(inPlanNetworkIndicatorCode: ['Y', 'N']).size)
          end
        end
      end

      describe '#find_by' do
        it 'finds one' do
          assert(benefits.find_by(serviceTypeCodes: '30').is_a?(Hash))
          assert(benefits.find_by(serviceTypeCodes: '30', coverageLevelCode: 'IND').is_a?(Hash))
          assert(benefits.find_by(serviceTypeCodes: '30', coverageLevelCode: 'IND', timeQualifierCode: ChangeHealth::Models::EligibilityBenefit::REMAINING).is_a?(Hash))
        end
      end

      describe '#individual' do
        it 'filters individual' do
          assert_equal(7, benefits.individual.size)
        end

        it 'can chain' do
          assert_equal(3, benefits.individual.where(serviceTypeCodes: '30').size)
        end
      end

      describe '#child' do
        it 'filters child' do
          assert_equal(0, benefits.child.size)
        end

        it 'can chain' do
          assert_equal(0, benefits.child.where(serviceTypeCodes: '30').size)
        end
      end

      describe '#employee' do
        it 'filters employee' do
          assert_equal(0, benefits.employee.size)
        end

        it 'can chain' do
          assert_equal(0, benefits.employee.where(serviceTypeCodes: '30').size)
        end
      end

      describe '#in_network' do
        it 'filters by in_plan_network' do
          assert_equal(6, benefits.in_network.size)
        end

        it 'can chain' do
          assert_equal(2, benefits.in_network.where(serviceTypeCodes: '30').size)
        end
      end

      describe 'filtering helpers' do
        describe '#visits' do
          it 'filters by time visit' do
            assert_equal(benefits.where(timeQualifierCode: ChangeHealth::Models::EligibilityBenefit::VISIT), benefits.visits)
          end
        end

        describe '#years' do
          it 'filters by time year' do
            assert_equal(benefits.where(timeQualifierCode: ChangeHealth::Models::EligibilityBenefit::YEAR), benefits.years)
          end
        end

        describe '#remainings' do
          it 'filters by time remaining' do
            assert_equal(benefits.where(timeQualifierCode: ChangeHealth::Models::EligibilityBenefit::REMAINING), benefits.remainings)
          end
        end

        describe '#out_of_pockets' do
          it 'filters by time out_of_pocket' do
            assert_equal(benefits.where(code: ChangeHealth::Models::EligibilityBenefit::OUT_OF_POCKET), benefits.out_of_pockets)
            assert_equal(benefits.where(code: ChangeHealth::Models::EligibilityBenefit::OUT_OF_POCKET), benefits.oops)
          end
        end

        describe '#copayments' do
          it 'filters by time copayments' do
            assert_equal(benefits.where(code: ChangeHealth::Models::EligibilityBenefit::COPAYMENT), benefits.copayments)
            assert_equal(benefits.where(code: ChangeHealth::Models::EligibilityBenefit::COPAYMENT), benefits.copays)
          end
        end

        describe '#deductibles' do
          it 'filters by time deductibles' do
            assert_equal(benefits.where(code: ChangeHealth::Models::EligibilityBenefit::DEDUCTIBLE), benefits.deductibles)
          end
        end

        describe '#coinsurances' do
          it 'filters by time coinsurances' do
            assert_equal(benefits.where(code: ChangeHealth::Models::EligibilityBenefit::COINSURANCE), benefits.coinsurances)
          end
        end
      end

      describe 'single value helpers' do
        describe '#individual_coinsurance_visit' do
          it 'finds the first one' do
            assert_equal(0.3, benefits.individual_coinsurance_visit.amount)
          end

          it 'can filter by more args' do
            assert_nil(benefits.individual_coinsurance_visit(serviceTypeCodes: 'INVALID'))
          end
        end

        describe '#individual_oop_remaining' do
          it 'finds the first one' do
            assert_equal(4195.37, benefits.individual_oop_remaining.amount)
            assert_equal(4195.37, benefits.individual_out_of_pocket_remaining.amount)
          end

          it 'can filter by more args' do
            assert_nil(benefits.individual_oop_remaining(serviceTypeCodes: 'INVALID'))
          end
        end

        describe '#individual_oop_total' do
          it 'finds the first one' do
            assert_equal(5500, benefits.individual_oop_total.amount)
            assert_equal(5500, benefits.individual_out_of_pocket_total.amount)
          end

          it 'can filter by more args' do
            assert_nil(benefits.individual_oop_total(serviceTypeCodes: 'INVALID'))
          end
        end

        describe '#individual_copayment_visit' do
          it 'finds the first one' do
            assert_equal(30, benefits.individual_copayment_visit.amount)
            assert_equal(30, benefits.individual_copay_visit.amount)
          end

          it 'can filter by more args' do
            assert_equal(0, benefits.individual_copayment_visit(serviceTypeCodes: 'BZ').amount)
          end
        end

        describe 'deductible' do
          let(:json_data) { load_sample('000045.example.response.json', parse: true) }
          let(:edata) { ChangeHealth::Models::EligibilityData.new(data: json_data) }
          let(:benefits) { edata.benefits }
          let(:benefit) { benefits.first }

          describe '#individual_deductible_remaining' do
            it 'finds the first one' do
              assert_equal(0, benefits.individual_deductible_remaining.amount)
            end

            it 'can filter by more args' do
              assert_nil(benefits.individual_deductible_remaining(serviceTypeCodes: 'INVALID'))
            end
          end

          describe '#individual_deductible_total' do
            it 'finds the first one' do
              assert_equal(500, benefits.individual_deductible_total.amount)
            end

            it 'can filter by more args' do
              assert_nil(benefits.individual_deductible_total(serviceTypeCodes: 'INVALID'))
            end
          end
        end
      end
    end
  end
end
