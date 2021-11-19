module ChangeHealth
  module Response
    module Claim
      class ReportInfoClaimStatus < Hashie::Trash
        property :status_category_codes, required: false
        property :total_charge_amount, required: false
        property :status_information_effective_date, required: false

        def add_status_category_code(status_category_code)
          self[:status_category_codes] ||= []
          self[:status_category_codes] << status_category_code
        end
      end
    end
  end
end
