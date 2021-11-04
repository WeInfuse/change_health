require 'test_helper'

class ReportListDataTest < Minitest::Test
  describe 'report list data' do
    let(:json_data) { load_sample('claim/report/list.example.response.json', parse: true) }
    let(:report_list_data) { ChangeHealth::Response::Claim::ReportListData.new(data: json_data) }

    describe '#report_names' do
      it 'accesses report_names list' do
        assert_equal(11, report_list_data.report_names.size)
      end
    end
  end
end
