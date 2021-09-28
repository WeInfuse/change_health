module ChangeHealth
  module Models
    module Claim
      class SubmissionData < ChangeHealth::Models::ResponseData

        %w(controlNumber status tradingPartnerId tradingPartnerServiceId).each do |v|
          define_method(v) do
            @raw.dig(v)
          end
        end

        alias_method :control_number, :controlNumber
        alias_method :trading_partner_id, :tradingPartnerId
        alias_method :trading_partner_service_id, :tradingPartnerServiceId

        def trading_partner?(name)
          self.trading_partner_id == name || trading_partner_service_id == name
        end

      end
    end
  end
end
