# frozen_string_literal: true

module ChangeHealth
  class ChangeHealthException < StandardError
    def self.from_response(response, msg: nil)
      error_msg = nil

      begin
        error_msg = parse_error_msg(response.parsed_response)
      rescue JSON::ParserError
        error_msg = response.body
      end

      ChangeHealthException.new("Failed #{msg}: HTTP code: #{response&.code} MSG: #{error_msg}")
    end

    def self.parse_error_msg(error_response)
      if error_response.is_a?(Hash) && error_response.include?('error_description')
        error_response['error_description']
      else
        error_response
      end
    end
  end
end
