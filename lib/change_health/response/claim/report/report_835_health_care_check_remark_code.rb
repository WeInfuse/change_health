# frozen_string_literal: true

module ChangeHealth
  module Response
    module Claim
      class Report835HealthCareCheckRemarkCode < Hashie::Trash
        property :code_list_qualifier_code, required: false
        property :code_list_qualifier_code_value, required: false
        property :remark_code, required: false
      end
    end
  end
end
