module ChangeHealth
  module Models
    class Error
      attr_reader :data

      SIMPLE_RETRY_CODES = %w[
        42
        80
      ].freeze

      NO_RESUBMIT_MESSAGES = %w[
        resubmission not allowed
        do not resubmit
      ].freeze

      def initialize(data)
        @data = data
      end

      def message
        field_message || code_message
      end

      def field_message
        "#{field}: #{description}" if field?
      end

      def code_message
        "#{code}: #{description}" if code?
      end

      def retryable?
        code? && SIMPLE_RETRY_CODES.include?(code) && followupAction? && NO_RESUBMIT_MESSAGES.none? {|msg| followupAction.downcase.include?(msg) }
      end

      %w[field description code followupAction location].each do |method_name|
        define_method("#{method_name}?") do
          false == send(method_name).nil?
        end

        define_method("#{method_name}") do
          @data[method_name]
        end
      end
    end

    class EligibilityData
      attr_reader :response, :raw

      ACTIVE = '1'
      INACTIVE = '6'

      PARSE_DATE = ->(d) {
        begin
          d = Date.strptime(d, ChangeHealth::Models::DATE_FORMAT)
        rescue
        end

        d
      }

      def initialize(data: nil, response: nil)
        @response = response
        @raw      = data

        begin
          @raw ||= response&.parsed_response
        rescue JSON::ParserError
        end

        @raw ||= {}
      end

      def active?(service_code: '30')
        return ACTIVE == plan_status(service_code: service_code).dig('statusCode')
      end

      def inactive?(service_code: '30')
        return INACTIVE == plan_status(service_code: service_code).dig('statusCode')
      end

      def errors?
        self.errors.is_a?(Array) && false == self.errors.empty?
      end

      def errors
        errors = @raw.dig('errors') || []

        errors.flatten.map {|error| ChangeHealth::Models::Error.new(error) }
      end

      def recommend_retry?
        return false if errors.empty?

        error_codes = errors.select(&:code?)

        return false if error_codes.empty?

        return error_codes.all?(&:retryable?)
      end

      def dependents?
        true == self.dependents&.any?
      end

      %w(planStatus benefitsInformation controlNumber planDateInformation dependents).each do |v|
        define_method(v) do
          @raw.dig(v)
        end
      end

      %w(eligibilityBegin planBegin service).each do |f|
        define_method(f) do
          return PARSE_DATE.call(self.date_info&.dig(f))
        end
      end
      alias_method :eligibility_begin_date, :eligibilityBegin
      alias_method :plan_begin_date, :planBegin
      alias_method :service_date, :service

      def plan_date_range
        pd = self.date_info&.dig('plan') || ''
        pd.split('-')
      end

      def plan_date_range_start
        ChangeHealth::Models::EligibilityData::PARSE_DATE.call(self.plan_date_range[0])
      end

      def plan_date_range_end
        ChangeHealth::Models::EligibilityData::PARSE_DATE.call(self.plan_date_range[1])
      end

      def plan_status(service_code: )
        self.planStatus&.find {|plan| plan.dig('serviceTypeCodes')&.include?(service_code) } || {}
      end

      def benefits
        kname   = "ChangeHealth::Models::EligibilityBenefits#{self.trading_partner_id&.upcase}"
        klazz   = Object.const_get(kname) if Module.const_defined?(kname)
        klazz ||= ChangeHealth::Models::EligibilityBenefits

        if klazz.respond_to?(:factory)
          klazz = klazz.factory(self)
        end

        klazz.new(self.benefitsInformation || [])
      end

      def medicare?(**kwargs)
        false == benefits.empty? && benefits.where(kwargs).all? {|b| b.medicare? }
      end

      def plan?(name)
        self.plan_names.any? {|pname| name == pname }
      end

      def plan_names
        self.planStatus&.map {|plan_status| plan_status['planDetails'] }&.compact || []
      end

      def trading_partner?(name)
        self.trading_partner_id == name
      end

      def trading_partner_id
        @raw['tradingPartnerServiceId']
      end

      alias_method :control_number, :controlNumber
      alias_method :benefits_information, :benefitsInformation
      alias_method :plan_statuses, :planStatus
      alias_method :date_info, :planDateInformation
    end
  end
end
