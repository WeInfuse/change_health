module ChangeHealth
  module Models
    class EligibilityBenefits < Array
      def initialize(benefits)
        super(benefits.map {|benefit| ChangeHealth::Models::EligibilityBenefit.new(benefit) })
      end

      def where(**kwargs)
        self.class.new(self.select {|benefit| kwargs.all? {|k,v| benefit_matches?(benefit, k, v) } })
      end

      def where_not(**kwargs)
        self.class.new(self.reject {|benefit| kwargs.all? {|k,v| benefit_matches?(benefit, k, v) } })
      end

      def +(other_obj)
        self.class.new(self.to_a + other_obj.to_a)
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

      %w(family individual employee child employee_and_child).each do |method|
        define_method(method) do
          self.send("#{method}s")
        end

        %w(copayment coinsurance).each do |type_mod|
          method_name = "#{method}_#{type_mod}"

          define_method(method_name) do |**kwargs|
            self.send(method).send("#{type_mod}s").where(kwargs).first
          end

          if ('copayment' == type_mod)
            define_method(method_name.gsub('copayment', 'copay')) do |**kwargs|
              self.send(method_name, kwargs)
            end
          end
        end

        %w(deductible out_of_pocket).each do |type_mod|
          %w(year remaining).each do |time_mod|
            method_name = "#{method}_#{type_mod}_#{time_mod}"

            define_method(method_name) do |**kwargs|
              self.send(method).send("#{type_mod}s").send("#{time_mod}s").where(kwargs).first || self.send(method).send("#{type_mod}s").where(kwargs).first
            end

            if ('out_of_pocket' == type_mod)
              define_method(method_name.gsub('out_of_pocket', 'oop')) do |**kwargs|
                self.send(method_name, kwargs)
              end

              if ('year' == time_mod)
                define_method(method_name.gsub('out_of_pocket', 'oop').gsub('year', 'total')) do |**kwargs|
                  self.send(method_name, kwargs)
                end
              end
            end

            if ('year' == time_mod)
              define_method(method_name.gsub('year', 'total')) do |**kwargs|
                self.send(method_name, kwargs)
              end
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
          elsif benefit.medicare?
            if :inPlanNetworkIndicatorCode == k.to_sym
              return false == benefit.in_plan_network? if 'N' == v
              return benefit.in_plan_network? if 'Y' == v
            elsif :coverageLevelCode == k.to_sym
              return false == benefit.individual? if EligibilityBenefit::INDIVIDUAL != v
              return benefit.individual? if EligibilityBenefit::INDIVIDUAL == v
            end
          end

          return v == benefit[k]
        end
      end
    end
  end
end
