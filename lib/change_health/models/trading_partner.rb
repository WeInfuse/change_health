module ChangeHealth
  module Models
    class TradingPartner < Hashie::Trash
      include Hashie::Extensions::IndifferentAccess
      include Hashie::Extensions::IgnoreUndeclared

      property :service_id, required: true
      property :name, required: true
    end
  end
end
