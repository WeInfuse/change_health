module ChangeHealth
  module Response
    module Claim
      class Report835Payment < Hashie::Trash
        property :check_issue_or_eft_effective_date, required: false
        property :check_or_eft_trace_number, required: false
        property :claims, required: false
        property :payer_identifier, required: false
        property :payer_name, required: false
        property :payment_method_code, required: false
        property :report_creation_date, required: false
        property :report_name, required: false
        property :total_actual_provider_payment_amount, required: false
      end
    end
  end
end
