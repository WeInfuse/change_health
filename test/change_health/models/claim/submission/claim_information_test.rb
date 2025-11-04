require 'test_helper'

class ClaimInformationTest < Minitest::Test
  describe 'claim information' do
    let(:claim_information) do
      ChangeHealth::Models::Claim::ClaimInformation.new(benefits_assignment_certification_indicator: 'cat')
    end

    describe 'object' do
      describe 'serializes' do
        it 'can serialize to json' do
          result = JSON.parse(claim_information.to_json)

          assert_equal(claim_information.benefitsAssignmentCertificationIndicator,
                       result['benefitsAssignmentCertificationIndicator'])
        end
      end

      describe 'handles lists' do
        it 'defaults to no service lines' do
          assert_nil(claim_information.serviceLines)
        end

        it 'can add a service line' do
          service_line = {
            professionalService: 'cat'
          }
          claim_information.add_service_line(service_line)

          assert_equal(1, claim_information.serviceLines.size)
          assert_equal(service_line[:professionalService], claim_information.serviceLines.first[:professionalService])
        end

        it 'defaults to no health_care_code_information' do
          assert_nil(claim_information.healthCareCodeInformation)
        end

        it 'can add a health_care_code_information' do
          health_care_code_information = {
            diagnosisTypeCode: 'ABK',
            diagnosisCode: 'S93401A'
          }
          claim_information.add_health_care_code_information(health_care_code_information)

          assert_equal(1, claim_information.healthCareCodeInformation.size)
          assert_equal(health_care_code_information[:diagnosisTypeCode],
                       claim_information.healthCareCodeInformation.first[:diagnosisTypeCode])
        end
      end

      describe 'other payer name' do
        let(:other_payer_name) do
          ChangeHealth::Models::Claim::OtherPayerName.new(
            otherPayerClaimControlNumber: '12345',
            otherPayerIdentifier: '67890',
            otherPayerIdentifierTypeCode: 'XX',
            otherPayerOrganizationName: 'Some Payer'
          )
        end

        before do
          claim_information.otherSubscriberInformation = ChangeHealth::Models::Claim::OtherSubscriberInformation.new
        end

        it 'defaults to no other payer names' do
          assert_nil(claim_information.otherSubscriberInformation.otherPayerName)
        end

        it 'can add an other payer name' do
          claim_information.otherSubscriberInformation.otherPayerName = other_payer_name

          assert_equal(other_payer_name, claim_information.otherSubscriberInformation.otherPayerName)
          assert_equal(other_payer_name.otherPayerClaimControlNumber,
                       claim_information.otherSubscriberInformation.otherPayerName.otherPayerClaimControlNumber)
        end

        it 'can add other payer secondary identifiers' do
          secondary_identifier1 = ChangeHealth::Models::Claim::OtherPayerSecondaryIdentifier.new(
            qualifier: '01',
            identifier: 'ABC123'
          )
          secondary_identifier2 = ChangeHealth::Models::Claim::OtherPayerSecondaryIdentifier.new(
            qualifier: '02',
            identifier: 'DEF456'
          )

          other_payer_name.add_other_payer_secondary_identifier(secondary_identifier1)
          other_payer_name.add_other_payer_secondary_identifier(secondary_identifier2)

          claim_information.otherSubscriberInformation.otherPayerName = other_payer_name

          assert_equal(
            2,
            claim_information.otherSubscriberInformation.otherPayerName.otherPayerSecondaryIdentifier.size
          )
          assert_equal(
            secondary_identifier1.qualifier,
            claim_information.otherSubscriberInformation.otherPayerName.otherPayerSecondaryIdentifier.first.qualifier
          )
          assert_equal(
            secondary_identifier2.qualifier,
            claim_information.otherSubscriberInformation.otherPayerName.otherPayerSecondaryIdentifier.last.qualifier
          )
        end
      end
    end
  end
end
