# frozen_string_literal: true

module ChangeHealth
  module Models
    module Claim
      class InstitutionalService < Model
        property :description
        property :lineItemChargeAmount, from: :line_item_charge_amount
        property :measurementUnit, from: :measurement_unit
        property :procedureCode, from: :procedure_code
        property :procedureIdentifier, from: :procedure_identifier
        property :procedureModifiers, from: :procedure_modifiers
        property :serviceLineRevenueCode, from: :service_line_revenue_code
        property :serviceUnitCount, from: :service_unit_count
      end
    end
  end
end
