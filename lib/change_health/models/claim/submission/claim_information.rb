module ChangeHealth
  module Models
    module Claim
      class ClaimInformation < Hashie::Trash
        property :benefitsAssignmentCertificationIndicator, from: :benefits_assignment_certification_indicator, required: false
        property :claimChargeAmount, from: :claim_charge_amount, required: false
        property :claimFilingCode, from: :claim_filing_code, required: false
        property :claimFrequencyCode, from: :claim_frequency_code, required: false
        property :claimSupplementalInformation, from: :claim_supplemental_information, required: false
        property :healthCareCodeInformation, from: :health_care_code_information, required: false
        property :patientControlNumber, from: :patient_control_number, required: false
        property :placeOfServiceCode, from: :place_of_service_code, required: false
        property :planParticipationCode, from: :plan_participation_code, required: false
        property :releaseInformationCode, from: :release_information_code, required: false
        property :serviceFacilityLocation, from: :service_facility_location, required: false
        property :serviceLines, from: :service_lines, required: false
        property :signatureIndicator, from: :signature_indicator, required: false

        def create_group_adjustments(group_adjustments)
          adjustment_array = []
          [1, 2, 3].each do |i|
              if group_adjustments["adjustmentReasonCode"+"#{i}"]
                adjustment_array << {
                    adjustmentReasonCode: group_adjustments["adjustmentReasonCode"+"#{i}"],
                    adjustmentAmount: group_adjustments["adjustmentAmount"+"#{i}"]
                  }
            end
          end
          {
            adjustmentDetails: adjustment_array,
            adjustmentGroupCode: group_adjustments["claimAdjustmentGroupCode"]
          }
        end
      
        def create_adjustment_detail_array(other_subscriber_information)
          adjustment_details = []
          other_subscriber_information.each do |line_item|
            line_item_adjustments = line_item["serviceAdjustments"]
            line_item_adjustments.each do |group_adjustments|
              adjustment_details << create_group_adjustments(group_adjustments)
            end
          end
          adjustment_details
        end

        def create_other_subscriber_information(other_subscriber_information)
          create_adjustment_detail_array(other_subscriber_information)
        end

        def add_service_line(service_line)
          self[:serviceLines] ||= []
          self[:serviceLines] << service_line
        end

        def add_health_care_code_information(health_care_code_information)
          self[:healthCareCodeInformation] ||= []
          self[:healthCareCodeInformation] << health_care_code_information
        end
      end
    end
  end
end
