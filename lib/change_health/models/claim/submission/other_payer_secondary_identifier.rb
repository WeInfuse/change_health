# frozen_string_literal: true

module ChangeHealth
  module Models
    module Claim
      class OtherPayerSecondaryIdentifier < Model
        property :qualifier
        property :identifier
        property :otherIdentifier, from: :other_identifier
      end
    end
  end
end
