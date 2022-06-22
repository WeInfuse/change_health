require 'test_helper'

class DependentTest < Minitest::Test
  describe 'dependent' do
    let(:d) { Date.today }
    let(:dependent) { ChangeHealth::Models::Claim::Dependent.new(date_of_birth: d, member_id: '123') }
    let(:parsed) { JSON.parse(dependent.to_json) }

    describe 'object' do
      describe 'serializes' do
        it 'can serialize to json' do
          assert_equal(dependent.memberId, parsed['memberId'])
        end

        it 'converts dateOfBirth to specified date format' do
          assert_equal(d.strftime(ChangeHealth::Models::DATE_FORMAT), dependent.to_h[:dateOfBirth])
        end

        it 'works for as_json' do
          assert_equal(d.strftime(ChangeHealth::Models::DATE_FORMAT), dependent.as_json[:dateOfBirth])
        end

        it 'works for to_json' do
          assert_equal(d.strftime(ChangeHealth::Models::DATE_FORMAT), parsed['dateOfBirth'])
        end
      end
    end
  end
end
