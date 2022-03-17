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

      describe 'other_subscriber_information' do
         it 'creates adjustments correctly when there are multiple adjustments in a group code' do

          single_claim_json = [{ 'serviceDate' => '20200101', 'servicePaymentInformation' => { 'productOrServiceIDQualifier' => 'HC', 'productOrServiceIDQualifierValue' => 'Health Care Financing Administration Common Procedural Coding System (HCPCS) Codes', 'adjudicatedProcedureCode' => '21210', 'adjudicatedProcedureModifierCodes' => ['79'], 'lineItemChargeAmount' => '3600', 'lineItemProviderPaymentAmount' => '1455.51', 'unitsOfServicePaidCount' => '1', 'submittedProductOrServiceIDQualifier' => 'HC', 'submittedProductOrServiceIDQualifierValue' => 'Health Care Financing Administration Common Procedural Coding System (HCPCS) Codes', 'submittedAdjudicatedProcedureCode' => '21210', 'submittedAdjudicatedProcedureModifierCodes' => ['79', '51'] }, 'serviceAdjustments' => [{ 'claimAdjustmentGroupCode' => 'CO', 'claimAdjustmentGroupCodeValue' => 'Contractual Obligations', 'adjustmentReasonCode1' => '45', 'adjustmentAmount1' => '1685.95', 'adjustmentReasonCode2' => '253', 'adjustmentAmount2' => '29.7' }, { 'claimAdjustmentGroupCode' => 'PR', 'claimAdjustmentGroupCodeValue' => 'Patient Responsibility', 'adjustmentReasonCode1' => '1', 'adjustmentAmount1' => '57.54', 'adjustmentReasonCode2' => '2', 'adjustmentAmount2' => '371.3' }], 'serviceIdentification' => { 'locationNumber' => '11' }, 'serviceSupplementalAmounts' => { 'allowedActual' => '1914.05' } }, { 'serviceDate' => '20200101', 'servicePaymentInformation' => { 'productOrServiceIDQualifier' => 'HC', 'productOrServiceIDQualifierValue' => 'Health Care Financing Administration Common Procedural Coding System (HCPCS) Codes', 'adjudicatedProcedureCode' => '21026', 'adjudicatedProcedureModifierCodes' => ['79', '51'], 'lineItemChargeAmount' => '1890', 'lineItemProviderPaymentAmount' => '217.29', 'unitsOfServicePaidCount' => '1' }, 'serviceAdjustments' => [{ 'claimAdjustmentGroupCode' => 'CO', 'claimAdjustmentGroupCodeValue' => 'Contractual Obligations', 'adjustmentReasonCode1' => '45', 'adjustmentAmount1' => '1335.71', 'adjustmentReasonCode2' => '253', 'adjustmentAmount2' => '4.43', 'adjustmentReasonCode3' => '59', 'adjustmentAmount3' => '277.14' }, { 'claimAdjustmentGroupCode' => 'PR', 'claimAdjustmentGroupCodeValue' => 'Patient Responsibility', 'adjustmentReasonCode1' => '2', 'adjustmentAmount1' => '55.43' }], 'serviceIdentification' => { 'locationNumber' => '11' }, 'serviceSupplementalAmounts' => { 'allowedActual' => '277.15' } }, { 'serviceDate' => '20200101', 'servicePaymentInformation' => { 'productOrServiceIDQualifier' => 'HC', 'productOrServiceIDQualifierValue' => 'Health Care Financing Administration Common Procedural Coding System (HCPCS) Codes', 'adjudicatedProcedureCode' => '21208', 'adjudicatedProcedureModifierCodes' => ['79', '51'], 'lineItemChargeAmount' => '1836', 'lineItemProviderPaymentAmount' => '648.83', 'unitsOfServicePaidCount' => '1' }, 'serviceAdjustments' => [{ 'claimAdjustmentGroupCode' => 'CO', 'claimAdjustmentGroupCodeValue' => 'Contractual Obligations', 'adjustmentReasonCode1' => '45', 'adjustmentAmount1' => '180.82', 'adjustmentReasonCode2' => '253', 'adjustmentAmount2' => '13.24', 'adjustmentReasonCode3' => '59', 'adjustmentAmount3' => '827.59' }, { 'claimAdjustmentGroupCode' => 'PR', 'claimAdjustmentGroupCodeValue' => 'Patient Responsibility', 'adjustmentReasonCode1' => '2', 'adjustmentAmount1' => '165.52' }], 'serviceIdentification' => { 'locationNumber' => '11' }, 'serviceSupplementalAmounts' => { 'allowedActual' => '827.59' } }, { 'serviceDate' => '20200101', 'servicePaymentInformation' => { 'productOrServiceIDQualifier' => 'HC', 'productOrServiceIDQualifierValue' => 'Health Care Financing Administration Common Procedural Coding System (HCPCS) Codes', 'adjudicatedProcedureCode' => '30580', 'adjudicatedProcedureModifierCodes' => ['79', '51'], 'lineItemChargeAmount' => '1680', 'lineItemProviderPaymentAmount' => '241.5', 'unitsOfServicePaidCount' => '1' }, 'serviceAdjustments' => [{ 'claimAdjustmentGroupCode' => 'CO', 'claimAdjustmentGroupCodeValue' => 'Contractual Obligations', 'adjustmentReasonCode1' => '45', 'adjustmentAmount1' => '1063.93', 'adjustmentReasonCode2' => '253', 'adjustmentAmount2' => '4.93', 'adjustmentReasonCode3' => '59', 'adjustmentAmount3' => '308.03' }, { 'claimAdjustmentGroupCode' => 'PR', 'claimAdjustmentGroupCodeValue' => 'Patient Responsibility', 'adjustmentReasonCode1' => '2', 'adjustmentAmount1' => '61.61' }], 'serviceIdentification' => { 'locationNumber' => '11' }, 'serviceSupplementalAmounts' => { 'allowedActual' => '308.04' } }]

          # puts JSON.pretty_generate(single_claim_json)
          final = claim_information.create_other_subscriber_information(single_claim_json)
          puts "FINAL" * 10
          puts JSON.pretty_generate(final)
        end
      end
    end
  end
end
