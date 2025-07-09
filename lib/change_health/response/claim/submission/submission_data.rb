# frozen_string_literal: true

module ChangeHealth
  module Response
    module Claim
      class SubmissionData < ChangeHealth::Response::ResponseData
        %w[controlNumber status tradingPartnerId tradingPartnerServiceId].each do |v|
          define_method(v) do
            @raw[v]
          end
        end

        alias control_number controlNumber
        alias trading_partner_id tradingPartnerId
        alias trading_partner_service_id tradingPartnerServiceId

        def trading_partner?(name)
          trading_partner_id == name || trading_partner_service_id == name
        end
      end
    end
  end
end
