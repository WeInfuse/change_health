require 'test_helper'

class Report835ClaimTest < Minitest::Test
  describe 'report claim lists' do
    let(:report_claim) { ChangeHealth::Response::Claim::Report835Claim.new }

    describe 'procedure_codes' do
      it 'defaults to no procedure_codes' do
        assert_nil(report_claim.procedure_codes)
      end

      it 'gets procedure codes from service lines' do
        procedure_code = 'mycode'
        service_line = ChangeHealth::Response::Claim::Report835ServiceLine.new(
          adjudicated_procedure_code: procedure_code
        )
        report_claim.service_lines = [service_line]

        assert_equal(1, report_claim.procedure_codes.size)
        assert_equal(procedure_code, report_claim.procedure_codes.first)
      end
    end
  end
end
