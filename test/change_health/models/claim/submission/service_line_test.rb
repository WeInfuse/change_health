require 'test_helper'

class ServiceLineTest < Minitest::Test
  describe 'encounter' do
    let(:d) { Date.today }
    let(:service_line) { ChangeHealth::Models::Claim::ServiceLine.new(service_date: d, professional_service: 'cat') }
    let(:parsed) { JSON.parse(service_line.to_json) }

    describe 'object' do
      describe 'serializes' do
        it 'can serialize to json' do
          assert_equal(service_line.professionalService, parsed['professionalService'])
        end

        it "converts serviceDate to specified date format" do
          assert_equal(d.strftime(ChangeHealth::Models::DATE_FORMAT), service_line.to_h[:serviceDate])
        end

        it "works for as_json" do
          assert_equal(d.strftime(ChangeHealth::Models::DATE_FORMAT), service_line.as_json[:serviceDate])
        end

        it "works for to_json" do
          assert_equal(d.strftime(ChangeHealth::Models::DATE_FORMAT), parsed['serviceDate'])
        end
      end
    end
  end
end
