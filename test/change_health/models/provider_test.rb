require 'test_helper'

class SubscriberTest < Minitest::Test
  describe 'subscriber' do
    let(:d) { Date.today }
    let(:subscriber) { ChangeHealth::Models::Subscriber.new(date_of_birth: d, member_id: '123') }

    describe 'object' do
      describe 'serializes' do
        it 'can serialize to json' do
          result = JSON.parse(subscriber.to_json)

          assert_equal(subscriber.memberId, result['memberId'])
        end

        it "converts dateOfBirth to specified date format" do
          assert_equal(d.strftime(ChangeHealth::Models::DATE_FORMAT), subscriber.to_h[:dateOfBirth])
        end

        it "works for json" do
          assert_equal(d.strftime(ChangeHealth::Models::DATE_FORMAT), subscriber.as_json[:dateOfBirth])
        end
      end
    end
  end
end
