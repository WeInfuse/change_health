require 'test_helper'

class ProviderTest < Minitest::Test
  describe 'provider' do
    let(:provider) { ChangeHealth::Models::Provider.new(npi: 'cat') }

    describe 'object' do
      describe 'serializes' do
        it 'can serialize to json' do
          result = JSON.parse(provider.to_json)

          assert_equal(provider.npi, result['npi'])
        end
      end
    end
  end
end
