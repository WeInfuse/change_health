module ChangeHealth
  class ChangeHealthException < Exception
    def self.from_response(response, msg: nil)
      exception_msg = "Failed #{msg}:"
      exception_msg << " HTTP code: #{response.code} MSG: "

      begin
        error_response = response.parsed_response

        if (error_response.is_a?(Hash) && error_response.include?("error_description"))
          exception_msg << error_response["error_description"]
        else
          exception_msg << error_response
        end
      rescue JSON::ParserError
        exception_msg << response.body
      end

      return ChangeHealthException.new(exception_msg)
    end
  end
end
