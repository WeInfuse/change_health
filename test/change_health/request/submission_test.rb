require 'test_helper'

class SubmissionTest < Minitest::Test
  describe 'claim_submission' do
    let(:headers) do
      {
        submitter_id: 'submittedIdValue',
        biller_id: 'billerIdValue',
        username: 'usernameValue',
        password: 'passwordValue'
      }
    end
    let(:claim_submission) { ChangeHealth::Request::Claim::Submission.new(headers: headers) }

    let(:professional_endpoint) { ChangeHealth::Request::Claim::Submission::PROFESSIONAL_ENDPOINT }
    let(:institutional_endpoint) { ChangeHealth::Request::Claim::Submission::INSTITUTIONAL_ENDPOINT }

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
          provider = { firstName: 'jane' }
          claim_submission.add_provider(provider)
          assert_equal(1, claim_submission.providers.size)
          assert_equal(provider[:firstName], claim_submission.providers.first[:firstName])
        end
      end
    end

    describe 'api' do
      describe '#health_check' do
        let(:response) { build_response(file: 'health_check.response.json') }
        let(:professional_health_check_endpoint) do
          professional_endpoint + ChangeHealth::Request::Claim::Submission::HEALTH_CHECK_SUFFIX
        end
        let(:institutional_health_check_endpoint) do
          institutional_endpoint + ChangeHealth::Request::Claim::Submission::HEALTH_CHECK_SUFFIX
        end

        it 'calls professional health check' do
          stub_change_health(endpoint: professional_health_check_endpoint, response: response, verb: :get)

          claim_submission.class.health_check

          assert_requested(@stub)
        end

        it 'calls institutional health check' do
          stub_change_health(endpoint: institutional_health_check_endpoint, response: response, verb: :get)

          claim_submission.class.health_check(is_professional: false)

          assert_requested(@stub)
        end
      end

      describe '#validation mock' do
        let(:response) { build_response(file: '/claim/validation/validation.response.json') }
        let(:professional_validation_endpoint) do
          professional_endpoint + ChangeHealth::Request::Claim::Submission::VALIDATION_SUFFIX
        end
        let(:institutional_validation_endpoint) do
          institutional_endpoint + ChangeHealth::Request::Claim::Submission::VALIDATION_SUFFIX
        end

        describe 'professional' do
          before do
            stub_change_health(endpoint: professional_validation_endpoint, response: response)

            @validation_data = claim_submission.validation
          end

          it 'calls submission' do
            assert_requested(@stub)
          end

          it 'returns claim_validation data' do
            assert_equal(@validation_data.raw, @validation_data.response.parsed_response)
          end
        end

        describe 'institutional' do
          before do
            stub_change_health(endpoint: institutional_validation_endpoint, response: response)

            @validation_data = claim_submission.validation(is_professional: false)
          end

          it 'calls submission' do
            assert_requested(@stub)
          end

          it 'returns claim_validation data' do
            assert_equal(@validation_data.raw, @validation_data.response.parsed_response)
          end
        end
      end

      describe '#submission mock' do
        let(:response) { build_response(file: 'claim/submission/success.example.response.json') }
        let(:professional_submission_endpoint) do
          professional_endpoint + ChangeHealth::Request::Claim::Submission::SUBMISSION_SUFFIX
        end
        let(:institutional_submission_endpoint) do
          institutional_endpoint + ChangeHealth::Request::Claim::Submission::SUBMISSION_SUFFIX
        end

        describe 'professional' do
          before do
            stub_change_health(endpoint: professional_submission_endpoint, response: response)

            @submission_data = claim_submission.submission
          end

          it 'calls submission' do
            assert_requested(@stub)
          end

          it 'returns claim_submission data' do
            assert_equal(@submission_data.raw, @submission_data.response.parsed_response)
          end
        end

        describe 'institutional' do
          before do
            stub_change_health(endpoint: institutional_submission_endpoint, response: response)

            @submission_data = claim_submission.submission(is_professional: false)
          end

          it 'calls submission' do
            assert_requested(@stub)
          end

          it 'returns claim_submission data' do
            assert_equal(@submission_data.raw, @submission_data.response.parsed_response)
          end
        end

        describe 'headers' do
          describe 'professional' do
            it 'given headers' do
              expected = {
                'X-CHC-ClaimSubmission-BillerId' => 'billerIdValue',
                'X-CHC-ClaimSubmission-Pwd' => 'passwordValue',
                'X-CHC-ClaimSubmission-SubmitterId' => 'submittedIdValue',
                'X-CHC-ClaimSubmission-Username' => 'usernameValue'
              }
              assert_equal(expected, claim_submission.professional_headers)
            end
            it 'no headers' do
              assert_nil(ChangeHealth::Request::Claim::Submission.new.professional_headers)
            end
          end

          describe 'institutional' do
            it 'given headers' do
              expected = {
                'X-CHC-InstitutionalClaims-BillerId' => 'billerIdValue',
                'X-CHC-InstitutionalClaims-Pwd' => 'passwordValue',
                'X-CHC-InstitutionalClaims-SubmitterId' => 'submittedIdValue',
                'X-CHC-InstitutionalClaims-Username' => 'usernameValue'
              }
              assert_equal(expected, claim_submission.institutional_headers)
            end
            it 'no headers' do
              assert_nil(ChangeHealth::Request::Claim::Submission.new.institutional_headers)
            end
          end
        end
      end
    end

    describe '#self.endpoint' do
      it 'professional w/ suffix' do
        suffix = '/whatever'
        endpoint = ChangeHealth::Request::Claim::Submission.endpoint(
          is_professional: true,
          suffix: suffix
        )

        expected_endpoint = professional_endpoint + suffix
        assert_equal expected_endpoint, endpoint
      end

      it 'institutional w/out suffix' do
        endpoint = ChangeHealth::Request::Claim::Submission.endpoint(
          is_professional: false
        )
        assert_equal institutional_endpoint, endpoint
      end

      describe 'configuration override' do
        before do
          @config = ChangeHealth.configuration.to_h
        end

        after do
          ChangeHealth.configuration.from_h(@config)
        end

        it 'respects configuration' do
          new_endpoint = '/someotherendpoint'

          ChangeHealth.configuration.endpoints = {
            'ChangeHealth::Request::Claim::Submission' => new_endpoint
          }

          endpoint = ChangeHealth::Request::Claim::Submission.endpoint(
            is_professional: false,
            suffix: 'STUFF'
          )

          assert_equal new_endpoint, endpoint
        end
      end
    end
  end
end
