module ChangeHealth
  module Response
    module Claim
      class ReportClaim < Hashie::Trash
        property :patient_first_name, required: false
        property :patient_last_name, required: false
        property :payer_identification, required: false
        property :payer_name, required: false
        property :report_creation_date, required: false
        property :service_date_begin, required: false
        property :service_date_end, required: false
        property :service_provider_npi, required: false
      end
    end
  end
end
