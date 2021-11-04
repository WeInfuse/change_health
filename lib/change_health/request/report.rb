module ChangeHealth
  module Request
    module Claim
      class Report
        ENDPOINT = '/medicalnetwork/reports/v2'.freeze
        HEALTH_CHECK_ENDPOINT = ENDPOINT + '/healthcheck'.freeze

        def self.report_list
          ChangeHealth::Response::Claim::ReportListData.new(response: ChangeHealth::Connection.new.request(endpoint: ENDPOINT, verb: :get))
        end

        def self.get_report(report_name, as_json_report: true)
          return if report_name.nil? || report_name.empty?

          individual_report_endpoint = ENDPOINT + '/' + report_name
          if as_json_report
            # https://developers.changehealthcare.com/eligibilityandclaims/docs/what-file-types-does-this-api-get-from-the-mailbox
            report_type = ChangeHealth::Response::Claim::ReportData.report_type(report_name)
            return if report_type.nil?

            individual_report_endpoint += '/' + report_type
          end

          ChangeHealth::Response::Claim::ReportData.new(report_name,
                                                        as_json_report,
                                                        response: ChangeHealth::Connection.new.request(endpoint: individual_report_endpoint, verb: :get))
        end

        def self.health_check
          ChangeHealth::Connection.new.request(endpoint: HEALTH_CHECK_ENDPOINT, verb: :get)
        end

        def self.ping
          self.health_check
        end
      end
    end
  end
end
