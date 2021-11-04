module ChangeHealth
  module Response
    module Claim
      class ReportListData < ChangeHealth::Response::ResponseData

        def report_names
          @raw.dig('reports')
        end
        
      end
    end
  end
end
