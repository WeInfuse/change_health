module ChangeHealth
  module Response
    module Claim
      class Report835Payment < Hashie::Trash
        property :check_issue_or_eft_effective_date
        property :check_or_eft_trace_number
        property :claims
        property :id
        property :payer_identifier
        property :payer_name
        property :payment_method_code
        property :payer_address
        property :provider_adjustments
        property :report_creation_date
        property :report_name
        property :total_actual_provider_payment_amount
      end
    end
  end
end
