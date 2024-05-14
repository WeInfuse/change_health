module ChangeHealth
  module Response
    module Claim
      class ReportClaim < Hashie::Trash
        property :id
        property :patient_first_name
        property :patient_last_name
        property :patient_member_id
        property :payer_identification
        property :payer_name
        property :report_creation_date
        property :report_name
        property :service_date_begin
        property :service_date_end
        property :service_provider_npi
      end
    end
  end
end
