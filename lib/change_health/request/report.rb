module ChangeHealth
  module Request
    module Claim
      class Report
        ENDPOINT = '/medicalnetwork/reports/v2'.freeze
        HEALTH_CHECK_ENDPOINT = ENDPOINT + '/healthcheck'.freeze

        def self.report_list(headers: nil)
          final_headers = ChangeHealth::Request::Claim::Report.report_headers(headers)
          ChangeHealth::Response::Claim::ReportListData.new(response: ChangeHealth::Connection.new.request(
            endpoint: ENDPOINT, verb: :get, headers: final_headers
          ))
        end

        def self.get_report(report_name, as_json_report: true, headers: nil)
          return if report_name.nil? || report_name.empty?

          final_headers = ChangeHealth::Request::Claim::Report.report_headers(headers)

          individual_report_endpoint = "#{ENDPOINT}/#{report_name}"

          # https://developers.changehealthcare.com/eligibilityandclaims/docs/what-file-types-does-this-api-get-from-the-mailbox
          if as_json_report
            report_type = ChangeHealth::Response::Claim::ReportData.report_type(report_name)
            individual_report_endpoint += "/#{report_type}"
          end

          response = ChangeHealth::Connection.new.request(
            endpoint: individual_report_endpoint,
            verb: :get,
            headers: final_headers
          )
          if ChangeHealth::Response::Claim::ReportData.is_277?(report_name)
            ChangeHealth::Response::Claim::Report277Data
              .new(report_name,
                   as_json_report,
                   response: response)
          elsif ChangeHealth::Response::Claim::ReportData.is_835?(report_name)
            ChangeHealth::Response::Claim::Report835Data
              .new(report_name,
                   as_json_report,
                   response: response)
          else
            ChangeHealth::Response::Claim::ReportData
              .new(report_name,
                   as_json_report,
                   response: response)
          end
        end

        def self.health_check
          ChangeHealth::Connection.new.request(endpoint: HEALTH_CHECK_ENDPOINT, verb: :get)
        end

        def self.ping
          health_check
        end

        def self.report_headers(headers)
          if headers
            extra_headers = {}
            extra_headers['X-CHC-Reports-Username'] = headers[:username]
            extra_headers['X-CHC-Reports-Password'] = headers[:password]
            extra_headers
          end
        end
      end
    end
  end
end
