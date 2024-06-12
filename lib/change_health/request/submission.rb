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

        property :attending
        property :billing
        property :billingPayToAddressName, from: :billing_pay_to_address_name
        property :claimInformation, from: :claim_information
        property :controlNumber, from: :control_number, required: true, default: ChangeHealth::Models::CONTROL_NUMBER
        property :dependent
        property :headers
        property :payToAddress, from: :pay_to_address
        property :providers
        property :receiver
        property :referring
        property :rendering
        property :submitter
        property :subscriber
        property :supervising
        # Need one or the other, trading partner id or trading partner service id
        property :tradingPartnerId, from: :trading_partner_id
        property :tradingPartnerName, from: :trading_partner_name
        property :tradingPartnerServiceId, from: :trading_partner_service_id

        def add_provider(provider)
          self[:providers] ||= []
          self[:providers] << provider
        end

        def submission(is_professional: true, headers: nil, endpoint: nil)
          endpoint ||= self.class.endpoint(
            is_professional: is_professional,
            suffix: SUBMISSION_SUFFIX
          )
          headers ||= is_professional ? professional_headers : institutional_headers
          ChangeHealth::Response::Claim::SubmissionData.new(
            response: ChangeHealth::Connection.new.request(
              endpoint: endpoint,
              body: to_h,
              headers: headers
            )
          )
        end

        def validation(is_professional: true)
          ChangeHealth::Response::Claim::SubmissionData.new(
            response: ChangeHealth::Connection.new.request(
              endpoint: self.class.endpoint(
                is_professional: is_professional,
                suffix: VALIDATION_SUFFIX
              ),
              body: to_h,
              headers: is_professional ? professional_headers : institutional_headers
            )
          )
        end

        def self.health_check(is_professional: true)
          ChangeHealth::Connection.new.request(
            endpoint: endpoint(
              is_professional: is_professional,
              suffix: HEALTH_CHECK_SUFFIX
            ),
            verb: :get
          )
        end

        def self.ping(is_professional: true)
          health_check(is_professional: is_professional)
        end

        def self.endpoint(is_professional: true, suffix: '')
          default_endpoint = is_professional ? PROFESSIONAL_ENDPOINT : INSTITUTIONAL_ENDPOINT
          default_endpoint += suffix

          ChangeHealth::Connection.endpoint_for(
            ChangeHealth::Request::Claim::Submission,
            default_endpoint: default_endpoint
          )
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
