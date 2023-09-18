require 'test_helper'

class BillingPayToAddressNameTest < Minitest::Test
  describe 'billing_pay_to_address_name' do
    let(:billing_pay_to_address_name) { ChangeHealth::Models::Claim::BillingPayToAddressName.new(entity_type_qualifier: '2') }
    let(:parsed) { JSON.parse(billing_pay_to_address_name.to_json) }

    describe 'serializes' do
      it 'can serialize to json' do
        assert_equal(billing_pay_to_address_name.entityTypeQualifier, parsed['entityTypeQualifier'])
        assert_equal(billing_pay_to_address_name.entityTypeQualifier, '2')
      end
    end
  end
end
