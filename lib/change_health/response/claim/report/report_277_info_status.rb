# frozen_string_literal: true

module ChangeHealth
  module Response
    module Claim
      class Report277InfoStatus < Hashie::Trash
        property :status_category_code, required: false
        property :status_category_code_value, required: false
        property :status_code, required: false
        property :status_code_value, required: false
      end
    end
  end
end
