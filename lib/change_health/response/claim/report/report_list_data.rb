# frozen_string_literal: true

module ChangeHealth
  module Response
    module Claim
      class ReportListData < ChangeHealth::Response::ResponseData
        def report_names
          @raw['reports']
        end
      end
    end
  end
end
