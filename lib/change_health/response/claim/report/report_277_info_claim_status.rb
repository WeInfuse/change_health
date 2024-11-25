module ChangeHealth
  module Response
    module Claim
      class Report277InfoClaimStatus < Hashie::Trash
        property :message, required: false
        property :info_statuses, required: false
        property :total_charge_amount, required: false
        property :status_information_effective_date, required: false

        def add_info_status(info_status)
          self[:info_statuses] ||= []
          self[:info_statuses] << info_status
        end
      end
    end
  end
end
