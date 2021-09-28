require 'test_helper'

class ClaimInformationTest < Minitest::Test
  describe 'claim information' do
    let(:claim_information) { ChangeHealth::Models::Claim::ClaimInformation.new(benefits_assignment_certification_indicator: 'cat') }

    describe 'object' do
      describe 'serializes' do
        it 'can serialize to json' do
          result = JSON.parse(claim_information.to_json)

          assert_equal(claim_information.benefitsAssignmentCertificationIndicator, result['benefitsAssignmentCertificationIndicator'])
        end
      end

      describe 'handles lists' do
        it 'defaults to no service lines' do
          assert_nil(claim_information.serviceLines)
        end

        it 'can add a service line' do
          serviceLine = {
            professionalService: "cat"
          }
          claim_information.add_service_line(serviceLine)
          assert_equal(1, claim_information.serviceLines.size)
          assert_equal(serviceLine[:professionalService], claim_information.serviceLines.first[:professionalService])
        end

        it 'defaults to no health_care_code_information' do
          assert_nil(claim_information.healthCareCodeInformation)
        end

        it 'can add a health_care_code_information' do
          health_care_code_information = {
            "diagnosisTypeCode": "ABK",
            "diagnosisCode": "S93401A"
          }
          claim_information.add_health_care_code_information(health_care_code_information)
          assert_equal(1, claim_information.healthCareCodeInformation.size)
          assert_equal(health_care_code_information[:diagnosisTypeCode], claim_information.healthCareCodeInformation.first[:diagnosisTypeCode])
        end
      end
    end
  end
end
