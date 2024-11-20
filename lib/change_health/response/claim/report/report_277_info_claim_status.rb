module ChangeHealth
  module Response
    module Claim
      class Report277InfoClaimStatus < Hashie::Trash
        property :message, required: false
        property :status_category_codes, required: false
        property :status_code_values, required: false
        property :total_charge_amount, required: false
        property :status_information_effective_date, required: false

        def add_status_category_code(status_category_code)
          self[:status_category_codes] ||= []
          self[:status_category_codes] << status_category_code
        end

        def add_status_code_value(status_code_value)
          self[:status_code_values] ||= []
          self[:status_code_values] << status_code_value
        end
      end
    end
  end
end
