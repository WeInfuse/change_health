module ChangeHealth
  module Models
    class EligibilityBenefits < Array
      def initialize(benefits)
        super(benefits.map {|benefit| ChangeHealth::Models::EligibilityBenefit.new(benefit) })
      end

      def where(**kwargs)
        EligibilityBenefits.new(self.select {|benefit| kwargs.all? {|k,v| benefit_matches?(benefit, k, v) } })
      end

      def find_by(**kwargs)
        self.find {|benefit| kwargs.all? {|k,v| benefit[k].is_a?(Array) ? benefit[k].include?(v) : v == benefit[k] } }
      end

      def in_network
        self.where(inPlanNetworkIndicatorCode: 'Y')
      end

      ChangeHealth::Models::EligibilityBenefit::HELPERS.each do |key, types|
        types.each do |method, value|
          define_method("#{method}s") do
            self.where(key => value)
          end
        end
      end

      def individual_coinsurance_visit(**kwargs)
        self.individual.coinsurances.visits.where(kwargs).first
      end

      %w(family individual employee child employee_and_child).each do |method|
        alias_method method, "#{method}s"

        %w(copayment deductible out_of_pocket).each do |type_mod|
          %w(year remaining visit).each do |time_mod|
            method_name = "#{method}_#{type_mod}_#{time_mod}"
            alias_name  = method_name.gsub('copayment', 'copay').gsub('out_of_pocket', 'oop')

            define_method(method_name) do |**kwargs|
              self.send(method).send("#{type_mod}s").send("#{time_mod}s").where(kwargs).first || self.send(method).send("#{type_mod}s").where(kwargs).first
            end

            alias_method alias_name, method_name if alias_name != method_name

            if method_name.include?('year')
              alias_method method_name.gsub('year', 'total'), method_name
              alias_method alias_name.gsub('year', 'total'), method_name
            end
          end
        end
      end

      alias_method :oops, :out_of_pockets
      alias_method :copays, :copayments

      private
      def benefit_matches?(benefit, k, v)
        if benefit[k].is_a?(Array)
          if v.is_a?(Array)
            return v.any? {|possible_v| benefit[k].include?(possible_v) }
          else
            return benefit[k].include?(v)
          end
        else
          if v.is_a?(Array)
            return v.include?(benefit[k])
          else
            return v == benefit[k]
          end
        end
      end
    end
  end
end
