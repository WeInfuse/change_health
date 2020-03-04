module ChangeHealth
  module Models
    class Provider < Hashie::Trash
      property :firstName, from: :first_name, required: false
      property :lastName, from: :last_name, required: false
      property :name, default: true, required: false
      property :npi, required: false
      property :organizationName, from: :organization_name, required: false
      property :payorId, from: :payer_id, required: false
      property :person, default: true, required: false
      property :providerCode, from: :provider_code, required: false
      property :providerName, from: :provider_name, required: false
      property :providerType, from: :provider_type, required: false
      property :referenceIdentification, from: :reference_identification, required: false
      property :serviceProviderNumber, from: :service_provider_number, required: false
      property :taxId, from: :tax_id, required: false

      alias_method :name?, :name
    end
  end
end
