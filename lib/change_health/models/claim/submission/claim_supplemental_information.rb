# frozen_string_literal: true

module ChangeHealth
  module Models
    module Claim
      class ClaimSupplementalInformation < Model
        property :claimControlNumber, from: :claim_control_number
        property :demoProjectIdentifier, from: :demo_project_identifier
        property :priorAuthorizationNumber, from: :prior_authorization_number
        property :referralNumber, from: :referral_number
        property :reportInformation, from: :report_information
      end
    end
  end
end
