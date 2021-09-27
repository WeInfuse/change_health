require 'test_helper'

class SubmissionTest < Minitest::Test
  describe 'claim_submission' do
    let(:claim_submission) { ChangeHealth::Models::Claim::Submission.new }

    describe 'object' do
      describe 'serializes' do
        it 'can serialize to json' do
          result = JSON.parse(claim_submission.to_json)

          assert_equal(claim_submission.controlNumber, result['controlNumber'])
        end

      end

      describe 'providers' do
        it 'defaults to no providers' do
          assert_nil(claim_submission.providers)
        end

        it 'can add a provider' do
          provider = { firstName: 'jane'}
          claim_submission.add_provider(provider)
          assert_equal(1, claim_submission.providers.size)
          assert_equal(provider[:firstName], claim_submission.providers.first[:firstName])
        end
      end
    end

    describe 'api' do
      describe '#health_check' do
        let(:response) { build_response(file: 'health_check.response.json') }
        let(:health_check_endpoint) { ChangeHealth::Models::Claim::Submission::HEALTH_CHECK_ENDPOINT }

        it 'calls health check' do
          stub_change_health(endpoint: health_check_endpoint, response: response, verb: :get)

          claim_submission.class.health_check

          assert_requested(@stub)
        end
      end

      describe '#submission mock' do
        let(:response) { build_response(file: 'claim/submission/success.example.response.json') }
        let(:health_check_endpoint) { ChangeHealth::Models::Claim::Submission::SUBMISSION_ENDPOINT }

        before do
          stub_change_health(endpoint: health_check_endpoint, response: response)

          @edata = claim_submission.submission
        end

        it 'calls health check' do
          assert_requested(@stub)
        end

        it 'returns claim_submission data' do
          assert_equal(@edata.raw, @edata.response.parsed_response)
        end
      end
    end
  end
end
