# frozen_string_literal: true

module ChangeHealth
  module Response
    module Claim
      class Report835ProviderAdjustment < Hashie::Trash
        property :adjustments
        property :fiscal_period_date, required: false
        property :provider_identifier, required: false

        def add_adjustment(adjustment)
          self[:adjustments] ||= []
          self[:adjustments] << adjustment
        end
      end
    end
  end
end
