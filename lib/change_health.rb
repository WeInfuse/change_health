# frozen_string_literal: true

require 'httparty'
require 'hashie'
require 'change_health/version'
require 'change_health/authentication'
require 'change_health/change_health_exception'
require 'change_health/connection'
require 'change_health/extensions'
require 'change_health/models/model'
require 'change_health/models/claim/submission/address'
require 'change_health/models/claim/submission/billing_pay_to_address_name'
require 'change_health/models/claim/submission/claim_code_information'
require 'change_health/models/claim/submission/claim_date_information'
require 'change_health/models/claim/submission/claim_information'
require 'change_health/models/claim/submission/claim_supplemental_information'
require 'change_health/models/claim/submission/contact_information'
require 'change_health/models/claim/submission/dependent'
require 'change_health/models/claim/submission/diagnosis'
require 'change_health/models/claim/submission/drug_identification'
require 'change_health/models/claim/submission/institutional_service'
require 'change_health/models/claim/submission/line_adjudication_information'
require 'change_health/models/claim/submission/other_payer_name'
require 'change_health/models/claim/submission/other_subscriber_information'
require 'change_health/models/claim/submission/other_subscriber_name'
require 'change_health/models/claim/submission/professional_service'
require 'change_health/models/claim/submission/provider'
require 'change_health/models/claim/submission/receiver'
require 'change_health/models/claim/submission/report_information'
require 'change_health/models/claim/submission/service_facility_location'
require 'change_health/models/claim/submission/service_line'
require 'change_health/models/claim/submission/submitter'
require 'change_health/models/claim/submission/subscriber'
require 'change_health/models/eligibility/encounter'
require 'change_health/models/eligibility/provider'
require 'change_health/models/eligibility/subscriber'
require 'change_health/models/trading_partner/trading_partner'
require 'change_health/request/eligibility'
require 'change_health/request/report'
require 'change_health/request/submission'
require 'change_health/request/trading_partner'
require 'change_health/response/error'
require 'change_health/response/response_data'
require 'change_health/response/claim/submission/submission_data'
require 'change_health/response/claim/report/report_list_data'
require 'change_health/response/claim/report/report_data'
require 'change_health/response/claim/report/report_277_data'
require 'change_health/response/claim/report/report_835_data'
require 'change_health/response/claim/report/report_claim'
require 'change_health/response/claim/report/report_277_claim'
require 'change_health/response/claim/report/report_277_info_status'
require 'change_health/response/claim/report/report_277_info_claim_status'
require 'change_health/response/claim/report/report_835_claim'
require 'change_health/response/claim/report/report_835_health_care_check_remark_code'
require 'change_health/response/claim/report/report_835_payment'
require 'change_health/response/claim/report/report_835_provider_adjustment'
require 'change_health/response/claim/report/report_835_service_adjustment'
require 'change_health/response/claim/report/report_835_service_line'
require 'change_health/response/eligibility/eligibility_benefit'
require 'change_health/response/eligibility/eligibility_benefits'
require 'change_health/response/eligibility/eligibility_data'
require 'change_health/response/trading_partner/trading_partner_data'
require 'change_health/response/trading_partner/trading_partners_data'

module ChangeHealth
  class Configuration
    attr_accessor :client_id, :client_secret, :grant_type, :auth_headers, :endpoints

    def initialize
      @auth_headers  = nil
      @client_id     = nil
      @client_secret = nil
      @endpoints     = nil
      @grant_type    = :client_credentials
    end

    def api_endpoint=(endpoint)
      Connection.base_uri(endpoint.freeze)
    end

    def api_endpoint
      Connection.base_uri
    end

    def to_h
      {
        auth_headers: @auth_headers,
        client_id: @client_id,
        client_secret: @client_secret,
        endpoints: @endpoints,
        grant_type: @grant_type,
        api_endpoint: api_endpoint
      }
    end

    def from_h(other_hash)
      self.auth_headers  = other_hash[:auth_headers]
      self.client_id     = other_hash[:client_id]
      self.client_secret = other_hash[:client_secret]
      self.endpoints     = other_hash[:endpoints]
      self.grant_type    = other_hash[:grant_type]
      self.api_endpoint  = other_hash[:api_endpoint]

      self
    end
  end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end

  # ChangeHealth API client
  class ChangeHealthClient
    class << self
      def connection
        @connection ||= Connection.new
      end

      def release
        @connection = nil
      end
    end
  end
end
