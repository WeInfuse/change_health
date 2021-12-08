require 'test_helper'

class ReportDataTest < Minitest::Test
  describe 'report type' do
    it '277' do
      report_name = 'X3000000.XX'
      assert_equal '277', ChangeHealth::Response::Claim::ReportData.report_type(report_name)
      assert ChangeHealth::Response::Claim::ReportData.is_277?(report_name)
    end

    it '835' do
      report_name = 'R5000000.XY'
      assert_equal '835', ChangeHealth::Response::Claim::ReportData.report_type(report_name)
      assert ChangeHealth::Response::Claim::ReportData.is_835?(report_name)
    end
  end

  describe 'json vs edi' do
    let(:report_name) { 'R5000000.XY' }
    let(:json_data) { load_sample("claim/report/report.#{report_name}.json.response.json", parse: true) }
    let(:report_data_json) { ChangeHealth::Response::Claim::ReportData.new(report_name, true, data: json_data) }
    let(:edi_data) { load_sample("claim/report/report.#{report_name}.edi.response.json", parse: true) }
    let(:report_data_edi) { ChangeHealth::Response::Claim::ReportData.new(report_name, false, data: json_data) }
    it 'json' do
      assert report_data_json.json?
      assert !report_data_json.edi?
    end

    it 'edi' do
      assert !report_data_edi.json?
      assert report_data_edi.edi?
    end
  end
end
