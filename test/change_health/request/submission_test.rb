require 'test_helper'

class SubmissionTest < Minitest::Test
  describe 'claim_submission' do
    let(:professional_headers) {
      {
        submitter_id: "submittedIdValue",
        biller_id: "billerIdValue",
        username: "usernameValue",
        password: "passwordValue",
      }
    }
    let(:claim_submission) { ChangeHealth::Request::Claim::Submission.new(headers: professional_headers) }

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
        let(:health_check_endpoint) { ChangeHealth::Request::Claim::Submission::HEALTH_CHECK_ENDPOINT }

        it 'calls health check' do
          stub_change_health(endpoint: health_check_endpoint, response: response, verb: :get)

          claim_submission.class.health_check

          assert_requested(@stub)
        end
      end

      describe '#validation mock' do
        let(:response) { build_response(file: '/claim/validation/validation.response.json') }
        let(:validation_endpoint) { ChangeHealth::Request::Claim::Submission::VALIDATION_ENDPOINT }

        before do
          stub_change_health(endpoint: validation_endpoint, response: response)

          @validation_data = claim_submission.validation
        end

        it 'calls submission' do
          assert_requested(@stub)
        end

        it 'returns claim_validation data' do
          assert_equal(@validation_data.raw, @validation_data.response.parsed_response)
        end
      end

      describe '#submission mock' do
        let(:response) { build_response(file: 'claim/submission/success.example.response.json') }
        let(:submission_endpoint) { ChangeHealth::Request::Claim::Submission::SUBMISSION_ENDPOINT }

        before do
          stub_change_health(endpoint: submission_endpoint, response: response)

          @submission_data = claim_submission.submission
        end

        it 'calls submission' do
          assert_requested(@stub)
        end

        it 'returns claim_submission data' do
          assert_equal(@submission_data.raw, @submission_data.response.parsed_response)
        end
      end
    end
  end
end
