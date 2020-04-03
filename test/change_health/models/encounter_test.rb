require 'test_helper'

class EncounterTest < Minitest::Test
  describe 'encounter' do
    let(:d) { Date.today }
    let(:encounter) { ChangeHealth::Models::Encounter.new(beginning_date_of_service: d, date_of_service: d, end_date_of_service: d) }
    let(:parsed) { JSON.parse(encounter.to_json()) }

    describe 'object' do
      describe 'serializes' do
        it 'can serialize to json' do
          assert_equal(encounter.date_range?, parsed['dateRange'])
        end

        [:beginningDateOfService, :dateOfService, :endDateOfService].each do |key|
          it "converts #{key} to specified date format" do
            assert_equal(d.strftime(ChangeHealth::Models::DATE_FORMAT), encounter.to_h[key])
          end

          it "works for as_json" do
            assert_equal(d.strftime(ChangeHealth::Models::DATE_FORMAT), encounter.as_json[key])
          end

          it "works for to_json" do
            assert_equal(d.strftime(ChangeHealth::Models::DATE_FORMAT), parsed[key.to_s])
          end
        end
      end
    end
  end
end
