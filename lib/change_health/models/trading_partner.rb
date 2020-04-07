module ChangeHealth
  module Models
    class TradingPartner < Hashie::Trash
      include Hashie::Extensions::IndifferentAccess
      include Hashie::Extensions::IgnoreUndeclared

      property :id, from: :tradingPartnerId, required: true
      property :name, from: :tradingPartnerName, required: true
    end
  end
end
