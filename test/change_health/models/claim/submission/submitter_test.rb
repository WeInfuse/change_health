require 'test_helper'

class SubmitterTest < Minitest::Test
  describe 'submitter' do
    let(:submitter) { ChangeHealth::Models::Claim::Submitter.new(organization_name: 'Fun Org') }

    describe 'object' do
      describe 'serializes' do
        it 'can serialize to json' do
          result = JSON.parse(submitter.to_json)

          assert_equal(submitter.organizationName, result['organizationName'])
        end
      end
    end
  end
end
