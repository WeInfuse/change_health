module ChangeHealth
  module Models
    class TradingPartner < Hashie::Trash
      include Hashie::Extensions::IndifferentAccess
      include Hashie::Extensions::IgnoreUndeclared

      property :alias, required: false
      property :line_of_business, required: false
      property :name, required: true
      property :plan_type, required: false
      property :service_id, required: true
    end
  end
end
