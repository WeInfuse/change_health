# frozen_string_literal: true

module ChangeHealth
  module Response
    class Error
      attr_reader :data

      SIMPLE_RETRY_CODES = %w[
        42
        80
      ].freeze

      NO_RESUBMIT_MESSAGES = [
        'resubmission not allowed',
        'do not resubmit'
      ].freeze

      DOWN_FIELD = 'Http Header'

      DOWN_MESSAGE = 'Please review http headers for this API, please contact support if you are unsure how to resolve.'

      def initialize(data)
        @data = data
      end

      def message
        field_message || code_message || description || @data.to_s
      end

      def field_message
        return "#{field}: #{description}" if field?
      end

      def code_message
        "#{code}: #{description}" if code?
      end

      def represents_down?
        field == DOWN_FIELD && description == DOWN_MESSAGE
      end

      def retryable?
        represents_down? ||
          (code? && SIMPLE_RETRY_CODES.include?(code) && can_follow_up?)
      end

      %w[field description code followupAction location].each do |method_name|
        define_method("#{method_name}?") do
          false == send(method_name).nil?
        end

        define_method(method_name.to_s) do
          @data[method_name] if @data.is_a?(Hash)
        end
      end

      private

      def can_follow_up?
        return true if followupAction.nil? || followupAction.empty?

        followupAction? && NO_RESUBMIT_MESSAGES.none? do |msg|
          followupAction.downcase.include?(msg)
        end
      end
    end
  end
end
