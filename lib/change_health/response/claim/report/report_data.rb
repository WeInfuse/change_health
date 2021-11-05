module ChangeHealth
  module Response
    module Claim
      class ReportData < ChangeHealth::Response::ResponseData
        attr_reader :report_name, :json
        alias_method :json?, :json

        def initialize(report_name, json, data: nil, response: nil)
          super(data: data, response: response)
          @report_name = report_name
          @json = json
        end

        def edi?
          !@json
        end

        def report_type
          self.class.report_type(@report_name)
        end

        def self.report_type(report_name)
          return '277' if is_277?(report_name)
          return '835' if is_835?(report_name)
        end

        def is_277?
          self.class.is_277?(@report_name)
        end

        def self.is_277?(report_name)
          report_name.start_with?('X3')
        end

        def is_835?
          self.class.is_835?(@report_name)
        end

        def self.is_835?(report_name)
          report_name.start_with?('R5')
        end
      end
    end
  end
end
