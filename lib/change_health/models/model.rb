module ChangeHealth
  module Models
    DATE_FORMAT = '%Y%m%d'
    DATE_FORMATTER = ->(d) {
      begin
        d = Date.parse(d) if d.is_a?(String)
      rescue ArgumentError
      end

      d = d.strftime(ChangeHealth::Models::DATE_FORMAT) if d.respond_to?(:strftime)

      d
    }

    class Model < Hashie::Trash
      def to_h
        result = super.to_h

        self.class.properties.each do |key|
          if key.to_s.downcase.include?('date')
            result[key] = ChangeHealth::Models::DATE_FORMATTER.call(result[key])
          end
        end

        result
      end

      def as_json(args = {})
        self.to_h
      end

      def to_json
        self.to_h.to_json
      end
    end
  end
end
