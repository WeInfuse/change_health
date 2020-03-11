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

      describe 'date_info' do
        it 'aliases benefitsDateInformation in hash' do
          assert_equal(benefit['benefitsDateInformation'], benefit.date_info)
        end

        describe 'helpers' do
          describe 'no data' do
            it 'digs more dates' do
              assert_nil(benefit.eligibility_begin_date)
              assert_nil(benefit.eligibility_end_date)
              assert_nil(benefit.plan_begin_date)
              assert_nil(benefit.plan_end_date)
              assert_nil(benefit.service_date)
            end
          end

          describe 'with data' do
            let(:benefit) {
              b = benefits.first
              b['benefitsDateInformation'] = {
                "eligibilityBegin": "20120501",
                "eligibilityEnd": "20200501",
                "planBegin": "20150101",
                "planEnd": "20200101",
                "service": "20160915"
              }
              b
            }

            it 'digs more dates' do
              assert_equal(Date.new(2012, 5, 1), benefit.eligibility_begin_date)
              assert_equal(Date.new(2020, 5, 1), benefit.eligibility_end_date)
              assert_equal(Date.new(2015, 1, 1), benefit.plan_begin_date)
              assert_equal(Date.new(2020, 1, 1), benefit.plan_end_date)
              assert_equal(Date.new(2016, 9, 15), benefit.service_date)
            end
          end

          describe 'with junky dates' do
            let(:benefit) {
              b = benefits.first
              b['benefitsDateInformation'] = { "planEnd": "12364762-264761" }
              b
            }

            it 'leaves it alone' do
              assert_equal('12364762-264761', benefit.plan_end_date)
            end
          end
        end
      end
    end
  end
end
