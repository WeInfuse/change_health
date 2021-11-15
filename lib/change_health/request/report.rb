module ChangeHealth
  module Request
    module Claim
      class Report
        ENDPOINT = '/medicalnetwork/reports/v2'.freeze
        HEALTH_CHECK_ENDPOINT = ENDPOINT + '/healthcheck'.freeze

        def self.report_list(headers: nil)
          final_headers = ChangeHealth::Request::Claim::Report.report_headers(headers)
          ChangeHealth::Response::Claim::ReportListData.new(response: ChangeHealth::Connection.new.request(endpoint: ENDPOINT, verb: :get, headers: final_headers))
        end

        def self.get_report(report_name, as_json_report: true, headers: nil)
          return if report_name.nil? || report_name.empty?
          final_headers =  ChangeHealth::Request::Claim::Report.report_headers(headers)

          individual_report_endpoint = ENDPOINT + '/' + report_name
          if as_json_report
            # https://developers.changehealthcare.com/eligibilityandclaims/docs/what-file-types-does-this-api-get-from-the-mailbox
            report_type = ChangeHealth::Response::Claim::ReportData.report_type(report_name)
            return if report_type.nil?

            individual_report_endpoint += '/' + report_type
          end

          ChangeHealth::Response::Claim::ReportData.new(report_name,
                                                        as_json_report,
                                                        response: ChangeHealth::Connection.new.request(endpoint: individual_report_endpoint, verb: :get, headers: final_headers))
        end

        def self.health_check
          ChangeHealth::Connection.new.request(endpoint: HEALTH_CHECK_ENDPOINT, verb: :get)
        end

        def self.ping
          self.health_check
        end

        def self.report_headers(headers)
          if headers
            extra_headers = {}
            extra_headers["X-CHC-Reports-Username"] = headers[:username]
            extra_headers["X-CHC-Reports-Password"] = headers[:password]
            extra_headers
          else
            nil
          end
        end
      end
    end
  end
end
