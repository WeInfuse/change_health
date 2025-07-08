require 'test_helper'

class EligibilityBenefitsTest < Minitest::Test
  describe 'eligibility data' do
    let(:json_data) { load_sample('000050.example.response.json', parse: true) }
    let(:edata) { ChangeHealth::Response::EligibilityData.new(data: json_data) }
    let(:benefits) { edata.benefits }
    let(:medicare) do
      b = benefits.last.dup
      b['insuranceTypeCode'] = 'MA'
      b.delete('coverageLevel')
      b.delete('coverageLevelCode')
      b.delete('inPlanNetworkIndicator')
      b.delete('inPlanNetworkIndicatorCode')
      b
    end

    describe 'benefits' do
      describe '#where' do
        it 'filters results' do
          assert_equal(3, benefits.where(serviceTypeCodes: '30', coverageLevelCode: 'IND').size)
          assert_equal(1, benefits.where(serviceTypeCodes: '30', coverageLevelCode: 'IND', timeQualifierCode: ChangeHealth::Response::EligibilityBenefit::REMAINING).size)
        end

        describe 'benefit key is an array' do
          it 'handles values' do
            assert_equal(3, benefits.where(serviceTypeCodes: '30').size)
          end

          it 'handles arrays' do
            assert_equal(5, benefits.where(serviceTypeCodes: %w[30 BZ]).size)
          end
        end

        describe 'benefit key is a value' do
          it 'handles values' do
            assert_equal(1, benefits.where(inPlanNetworkIndicatorCode: 'N').size)
          end

          it 'can handle arrays' do
            assert_equal(7, benefits.where(inPlanNetworkIndicatorCode: %w[Y N]).size)
          end
        end
      end

      describe '#where_not' do
        it 'filters results' do
          assert_equal(benefits.size - 3, benefits.where_not(serviceTypeCodes: '30', coverageLevelCode: 'IND').size)
          assert_equal(benefits.size - 1,
                       benefits.where_not(serviceTypeCodes: '30', coverageLevelCode: 'IND', timeQualifierCode: ChangeHealth::Response::EligibilityBenefit::REMAINING).size)
        end
      end

      describe '#+' do
        it 'concats benefits' do
          assert_equal(6, (benefits.where(serviceTypeCodes: '98') + benefits.where(serviceTypeCodes: 'BZ')).size)
        end
      end

      describe '#find_by' do
        it 'finds one' do
          assert_kind_of(Hash, benefits.find_by(serviceTypeCodes: '30'))
          assert_kind_of(Hash, benefits.find_by(serviceTypeCodes: '30', coverageLevelCode: 'IND'))
          assert_kind_of(Hash, benefits.find_by(serviceTypeCodes: '30', coverageLevelCode: 'IND', timeQualifierCode: ChangeHealth::Response::EligibilityBenefit::REMAINING))
        end
      end

      describe '#individual' do
        it 'filters individual' do
          assert_equal(7, benefits.individual.size)
        end

        it 'can chain' do
          assert_equal(3, benefits.individual.where(serviceTypeCodes: '30').size)
        end

        describe 'medicare' do
          it 'is individual' do
            b = benefits.dup
            b << medicare

            assert_predicate(medicare, :medicare?)
            assert_equal(8, b.individual.size)
          end
        end
      end

      describe '#family' do
        let(:json_data) { load_sample('000047.example.response.json', parse: true) }

        it 'filters family' do
          assert_equal(8, benefits.family.size)
        end

        it 'can chain' do
          assert_equal(0, benefits.family.where(serviceTypeCodes: '98').size)
        end

        describe 'medicare' do
          it 'is not family' do
            b = benefits.dup
            b << medicare

            assert_equal(8, benefits.family.size)
          end
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
        let(:json_data) { load_sample('000045.example.response.json', parse: true) }

        it 'filters employee' do
          assert_equal(52, benefits.employee.size)
        end

        it 'can chain' do
          assert_equal(5, benefits.employee.where(serviceTypeCodes: '30').size)
        end
      end

      describe '#employee_and_child' do
        let(:json_data) { load_sample('000047.example.response.json', parse: true) }

        it 'filters employee_and_child' do
          assert_equal(43, benefits.employee_and_child.size)
        end

        it 'can chain' do
          assert_equal(4, benefits.employee_and_child.where(serviceTypeCodes: '30').size)
        end
      end

      describe '#in_network' do
        it 'filters by in_plan_network' do
          assert_equal(6, benefits.in_network.size)
        end

        it 'can chain' do
          assert_equal(2, benefits.in_network.where(serviceTypeCodes: '30').size)
        end

        describe 'medicare' do
          it 'is in network' do
            b = benefits.dup
            b << medicare

            assert_equal(7, b.in_network.size)
          end
        end
      end

      describe 'filtering helpers' do
        describe '#visits' do
          it 'filters by time visit' do
            assert_equal(benefits.where(timeQualifierCode: ChangeHealth::Response::EligibilityBenefit::VISIT),
                         benefits.visits)
          end
        end

        describe '#years' do
          it 'filters by time year' do
            assert_equal(benefits.where(timeQualifierCode: ChangeHealth::Response::EligibilityBenefit::YEAR),
                         benefits.years)
          end
        end

        describe '#remainings' do
          it 'filters by time remaining' do
            assert_equal(benefits.where(timeQualifierCode: ChangeHealth::Response::EligibilityBenefit::REMAINING),
                         benefits.remainings)
          end
        end

        describe '#out_of_pockets' do
          it 'filters by time out_of_pocket' do
            assert_equal(benefits.where(code: ChangeHealth::Response::EligibilityBenefit::OUT_OF_POCKET),
                         benefits.out_of_pockets)
            assert_equal(benefits.where(code: ChangeHealth::Response::EligibilityBenefit::OUT_OF_POCKET), benefits.oops)
          end
        end

        describe '#copayments' do
          it 'filters by time copayments' do
            assert_equal(benefits.where(code: ChangeHealth::Response::EligibilityBenefit::COPAYMENT),
                         benefits.copayments)
            assert_equal(benefits.where(code: ChangeHealth::Response::EligibilityBenefit::COPAYMENT), benefits.copays)
          end
        end

        describe '#deductibles' do
          it 'filters by time deductibles' do
            assert_equal(benefits.where(code: ChangeHealth::Response::EligibilityBenefit::DEDUCTIBLE),
                         benefits.deductibles)
          end
        end

        describe '#coinsurances' do
          it 'filters by time coinsurances' do
            assert_equal(benefits.where(code: ChangeHealth::Response::EligibilityBenefit::COINSURANCE),
                         benefits.coinsurances)
          end
        end
      end

      describe 'single value helpers' do
        describe 'individual' do
          describe '#individual_coinsurance' do
            it 'finds the first one' do
              assert_in_delta(0.3, benefits.individual_coinsurance.amount)
            end

            it 'can filter by more args' do
              assert_nil(benefits.individual_coinsurance(serviceTypeCodes: 'INVALID'))
            end
          end

          describe '#individual_oop_remaining' do
            it 'finds the first one' do
              assert_in_delta(4195.37, benefits.individual_oop_remaining.amount)
              assert_in_delta(4195.37, benefits.individual_out_of_pocket_remaining.amount)
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

          describe '#individual_copayment' do
            it 'finds the first one' do
              assert_equal(30, benefits.individual_copayment.amount)
              assert_equal(30, benefits.individual_copay.amount)
            end

            it 'can filter by more args' do
              assert_equal(0, benefits.individual_copayment(serviceTypeCodes: 'BZ').amount)
            end
          end

          describe 'deductible' do
            let(:json_data) { load_sample('000045.example.response.json', parse: true) }

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

        describe 'family' do
          let(:json_data) { load_sample('000047.example.response.json', parse: true) }

          describe '#family_oop_remaining' do
            it 'finds the first one' do
              assert_in_delta(9355.76, benefits.family_oop_remaining.amount)
              assert_in_delta(9355.76, benefits.family_out_of_pocket_remaining.amount)
            end

            it 'can filter by more args' do
              assert_nil(benefits.family_oop_remaining(serviceTypeCodes: 'INVALID'))
            end
          end

          describe '#family_oop_total' do
            it 'finds the first one' do
              assert_equal(11_200, benefits.family_oop_total.amount)
              assert_equal(11_200, benefits.family_out_of_pocket_total.amount)
            end

            it 'can filter by more args' do
              assert_nil(benefits.family_oop_total(serviceTypeCodes: 'INVALID'))
            end
          end

          describe 'deductible' do
            describe '#family_deductible_remaining' do
              it 'finds the first one' do
                assert_in_delta(855.75, benefits.family_deductible_remaining.amount)
              end

              it 'can filter by more args' do
                assert_nil(benefits.family_deductible_remaining(serviceTypeCodes: 'INVALID'))
              end
            end

            describe '#family_deductible_total' do
              it 'finds the first one' do
                assert_equal(2000, benefits.family_deductible_total.amount)
              end

              it 'can filter by more args' do
                assert_nil(benefits.family_deductible_total(serviceTypeCodes: 'INVALID'))
              end
            end
          end
        end
      end
    end
  end
end
