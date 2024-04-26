require 'test_helper'

class ReportTest < Minitest::Test
  describe 'report' do
    let(:claim_report) { ChangeHealth::Request::Claim::Report }
    let(:report_headers) { { username: 'HeyThere', password: 'Bob' } }

    describe '#health_check' do
      let(:response) { build_response(file: 'health_check.response.json') }
      let(:health_check_endpoint) { ChangeHealth::Request::Claim::Report::HEALTH_CHECK_ENDPOINT }

      it 'calls health check' do
        stub_change_health(endpoint: health_check_endpoint, response: response, verb: :get)

        claim_report.health_check

        assert_requested(@stub)
      end
    end

    describe '#report_list' do
      let(:response) { build_response(file: 'claim/report/list.example.response.json') }
      let(:report_list_endpoint) { ChangeHealth::Request::Claim::Report::ENDPOINT }

      it 'calls report list' do
        stub_change_health(endpoint: report_list_endpoint, response: response, verb: :get)

        claim_report.report_list

        assert_requested(@stub)
      end

      it 'returns report list data' do
        stub_change_health(endpoint: report_list_endpoint, response: response, verb: :get)

        report_list_data = claim_report.report_list(headers: report_headers)

        assert_equal(report_list_data.raw, report_list_data.response.parsed_response)
      end

      it 'accepts more url' do
        more_url = '?someAdditionalUrl=more'
        whole_url = report_list_endpoint + more_url

        stub_change_health(endpoint: whole_url, response: response, verb: :get)

        claim_report.report_list(more_url: more_url)

        assert_requested(@stub)
      end
    end

    describe '#get_report' do
      describe 'json report' do
        let(:report_name) { 'R5000000.XY' }
        let(:response) { build_response(file: "claim/report/report.#{report_name}.json.response.json") }
        let(:single_report_endpoint) { ChangeHealth::Request::Claim::Report::ENDPOINT + "/#{report_name}/835" }

        before do
          stub_change_health(endpoint: single_report_endpoint, response: response, verb: :get)

          @report_data = claim_report.get_report(report_name, headers: report_headers)
        end

        it 'calls report' do
          assert_requested(@stub)
        end

        it 'returns report data' do
          assert_equal(@report_data.raw, @report_data.response.parsed_response)
        end

        it 'correct report type' do
          assert @report_data.is_a? ChangeHealth::Response::Claim::Report835Data
        end
      end
      describe 'edi report' do
        let(:report_name) { 'R5000000.XY' }
        let(:response) { build_response(file: "claim/report/report.#{report_name}.edi.response.json") }
        let(:single_report_endpoint) { ChangeHealth::Request::Claim::Report::ENDPOINT + "/#{report_name}" }

        before do
          stub_change_health(endpoint: single_report_endpoint, response: response, verb: :get)

          @report_data = claim_report.get_report(report_name, as_json_report: false, headers: report_headers)
        end

        it 'calls report' do
          assert_requested(@stub)
        end

        it 'returns report data' do
          assert_equal(@report_data.raw, @report_data.response.parsed_response)
        end
      end
      describe 'non 277 or 835 report' do
        let(:report_name) { 'AA000000.AA' }
        let(:response) { build_response(file: "claim/report/report.#{report_name}.response.json") }
        let(:single_report_endpoint) { ChangeHealth::Request::Claim::Report::ENDPOINT + "/#{report_name}" }

        before do
          stub_change_health(endpoint: single_report_endpoint, response: response, verb: :get)

          @report_data = claim_report.get_report(report_name, as_json_report: false, headers: report_headers)
        end

        it 'calls report' do
          assert_requested(@stub)
        end

        it 'returns report data' do
          assert_equal(@report_data.raw, @report_data.response.parsed_response)
          assert_equal('Some content', @report_data.raw['report_content'])
        end
      end
    end

    describe '#delete_report' do
      describe 'get response confirming deletion' do
        let(:report_name) { 'X3000000.XX' }
        let(:response) { build_response(file: "claim/report/report.#{report_name}.delete.response.json") }
        let(:single_report_endpoint) { ChangeHealth::Request::Claim::Report::ENDPOINT + "/#{report_name}" }

        before do
          stub_change_health(endpoint: single_report_endpoint, response: response, verb: :delete)

          @response = claim_report.delete_report(report_name, headers: report_headers)
        end

        it 'calls report' do
          assert_requested(@stub)
        end

        it 'returns response' do
          assert_equal('success', @response.parsed_response['status'])
        end
      end
    end

    describe 'can use custom endpoint' do
      let(:new_endpoint) { '/someNewReportEndpoint' }
      before do
        @config = ChangeHealth.configuration.to_h

        ChangeHealth.configuration.endpoints = {
          'ChangeHealth::Request::Claim::Report' => new_endpoint
        }
      end

      after do
        ChangeHealth.configuration.from_h(@config)
      end

      it '#report_list' do
        stub_change_health(endpoint: new_endpoint, verb: :get)
        claim_report.report_list
        assert_requested(@stub)
      end

      describe '#get_report' do
        let(:report_name) { 'R5000000.XY' }
        it 'custom beginning path' do
          stub_change_health(endpoint: "#{new_endpoint}/#{report_name}", verb: :get)
          claim_report.get_report(report_name, as_json_report: false)
          assert_requested(@stub)
        end

        it 'custom report type' do
          report_type = '999'
          stub_change_health(endpoint: "#{new_endpoint}/#{report_name}/#{report_type}", verb: :get)
          claim_report.get_report(report_name, report_type: report_type)
          assert_requested(@stub)
        end
      end

      it '#delete_report' do
        report_name = 'X3000000.XX'
        stub_change_health(endpoint: "#{new_endpoint}/#{report_name}", verb: :delete)
        claim_report.delete_report(report_name)
        assert_requested(@stub)
      end
    end
  end
end
