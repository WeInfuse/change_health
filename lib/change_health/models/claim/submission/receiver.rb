# frozen_string_literal: true

module ChangeHealth
  module Models
    module Claim
      class Receiver < Model
        property :organizationName, from: :organization_name
      end
    end
  end
end
