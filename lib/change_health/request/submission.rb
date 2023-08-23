module ChangeHealth
  module Request
    module Claim
      class Submission < Hashie::Trash
        PROFESSIONAL_ENDPOINT = '/medicalnetwork/professionalclaims/v3'.freeze
        INSTITUTIONAL_ENDPOINT = '/medicalnetwork/institutionalclaims/v1'.freeze
        HEALTH_CHECK_SUFFIX = '/healthcheck'.freeze
        SUBMISSION_SUFFIX = '/submission'.freeze
        VALIDATION_SUFFIX = '/validation'.freeze

        # Deprecated but still here for backwards compatibility
        ENDPOINT = PROFESSIONAL_ENDPOINT
        HEALTH_CHECK_ENDPOINT = ENDPOINT + '/healthcheck'.freeze
        SUBMISSION_ENDPOINT = ENDPOINT + '/submission'.freeze
        VALIDATION_ENDPOINT = ENDPOINT + '/validation'.freeze
        # End Deprecated

        property :claimInformation, from: :claim_information, required: false
        property :controlNumber, from: :control_number, required: true, default: ChangeHealth::Models::CONTROL_NUMBER
        property :dependent, required: false
        property :headers, required: false
        property :payToAddress, from: :pay_to_address, required: false
        property :providers, required: false
        property :receiver, required: false
        property :submitter, required: false
        property :subscriber, required: false
        # Need one or the other, trading partner id or trading partner service id
        property :tradingPartnerId, from: :trading_partner_id, required: false
        property :tradingPartnerServiceId, from: :trading_partner_service_id, required: false

        def add_provider(provider)
          self[:providers] ||= []
          self[:providers] << provider
        end

        def submission(is_professional: true)
          endpoint = is_professional ? PROFESSIONAL_ENDPOINT : INSTITUTIONAL_ENDPOINT
          endpoint += SUBMISSION_SUFFIX
          ChangeHealth::Response::Claim::SubmissionData.new(
            response: ChangeHealth::Connection.new.request(
              endpoint: endpoint,
              body: to_h,
              headers: is_professional ? professional_headers : institutional_headers
            )
          )
        end

        def validation(is_professional: true)
          endpoint = is_professional ? PROFESSIONAL_ENDPOINT : INSTITUTIONAL_ENDPOINT
          endpoint += VALIDATION_SUFFIX
          ChangeHealth::Response::Claim::SubmissionData.new(
            response: ChangeHealth::Connection.new.request(
              endpoint: endpoint,
              body: to_h,
              headers: is_professional ? professional_headers : institutional_headers
            )
          )
        end

        def self.health_check(is_professional: true)
          endpoint = is_professional ? PROFESSIONAL_ENDPOINT : INSTITUTIONAL_ENDPOINT
          endpoint += HEALTH_CHECK_SUFFIX
          ChangeHealth::Connection.new.request(endpoint: endpoint, verb: :get)
        end

        def self.ping(is_professional: true)
          health_check(is_professional: is_professional)
        end

        def professional_headers
          return unless self[:headers]

          {
            'X-CHC-ClaimSubmission-BillerId' => self[:headers][:biller_id],
            'X-CHC-ClaimSubmission-Pwd' => self[:headers][:password],
            'X-CHC-ClaimSubmission-SubmitterId' => self[:headers][:submitter_id],
            'X-CHC-ClaimSubmission-Username' => self[:headers][:username]
          }
        end

        def institutional_headers
          return unless self[:headers]

          {
            'X-CHC-InstitutionalClaims-BillerId' => self[:headers][:biller_id],
            'X-CHC-InstitutionalClaims-Pwd' => self[:headers][:password],
            'X-CHC-InstitutionalClaims-SubmitterId' => self[:headers][:submitter_id],
            'X-CHC-InstitutionalClaims-Username' => self[:headers][:username]
          }
        end
      end
    end
  end
end
