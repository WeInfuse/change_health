# frozen_string_literal: true

module ChangeHealth
  module Models
    module Claim
      class ServiceLineDateInformation < Model
        property :hemoglobinTestDate, from: :hemoglobin_test_date
      end
    end
  end
end
