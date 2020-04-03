require 'test_helper'

class SubscriberTest < Minitest::Test
  describe 'subscriber' do
    let(:d) { Date.today }
    let(:subscriber) { ChangeHealth::Models::Subscriber.new(date_of_birth: d, member_id: '123') }
    let(:parsed) { JSON.parse(subscriber.to_json) }

    describe 'object' do
      describe 'serializes' do
        it 'can serialize to json' do
          assert_equal(subscriber.memberId, parsed['memberId'])
        end

        it "converts dateOfBirth to specified date format" do
          assert_equal(d.strftime(ChangeHealth::Models::DATE_FORMAT), subscriber.to_h[:dateOfBirth])
        end

        it "works for as_json" do
          assert_equal(d.strftime(ChangeHealth::Models::DATE_FORMAT), subscriber.as_json[:dateOfBirth])
        end

        it "works for to_json" do
          assert_equal(d.strftime(ChangeHealth::Models::DATE_FORMAT), parsed['dateOfBirth'])
        end
      end
    end
  end
end
