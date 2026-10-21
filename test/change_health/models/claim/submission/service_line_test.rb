require 'test_helper'

class ServiceLineTest < Minitest::Test
  describe 'encounter' do
    let(:d) { Date.today }
    let(:service_line) { ChangeHealth::Models::Claim::ServiceLine.new(service_date: d, professional_service: 'cat') }
    let(:parsed) { JSON.parse(service_line.to_json) }

    describe 'object' do
      describe 'serializes' do
        it 'can serialize to json' do
          assert_equal(service_line.professionalService, parsed['professionalService'])
        end

        it 'converts serviceDate to specified date format' do
          assert_equal(d.strftime(ChangeHealth::Models::DATE_FORMAT), service_line.to_h[:serviceDate])
        end

        it 'works for as_json' do
          assert_equal(d.strftime(ChangeHealth::Models::DATE_FORMAT), service_line.as_json[:serviceDate])
        end

        it 'works for to_json' do
          assert_equal(d.strftime(ChangeHealth::Models::DATE_FORMAT), parsed['serviceDate'])
        end
      end
    end

    describe 'test results' do
      let(:result) do
        ChangeHealth::Models::Claim::TestResult.new(
          measurement_reference_identification_code: 'TR',
          measurement_qualifier: 'R1',
          test_results: '12.5'
        )
      end

      it 'omits testResults and serviceLineDateInformation when unset' do
        refute_includes(parsed.keys, 'testResults')
        refute_includes(parsed.keys, 'serviceLineDateInformation')
      end

      it 'maps test result properties' do
        assert_equal('TR', result.measurementReferenceIdentificationCode)
        assert_equal('R1', result.measurementQualifier)
        assert_equal('12.5', result.testResults)
      end

      it 'serializes an array of test results' do
        service_line.testResults = [result, result]

        expected = { 'measurementReferenceIdentificationCode' => 'TR', 'measurementQualifier' => 'R1',
                     'testResults' => '12.5' }

        assert_equal([expected, expected], parsed['testResults'])
      end
    end

    describe 'service line date information' do
      let(:date_information) do
        ChangeHealth::Models::Claim::ServiceLineDateInformation.new(hemoglobin_test_date: d)
      end

      it 'maps hemoglobin_test_date' do
        assert_equal(d, date_information.hemoglobinTestDate)
      end

      it 'formats hemoglobinTestDate as CCYYMMDD' do
        service_line.serviceLineDateInformation = date_information

        assert_equal(d.strftime('%Y%m%d'), parsed['serviceLineDateInformation']['hemoglobinTestDate'])
      end
    end
  end
end
