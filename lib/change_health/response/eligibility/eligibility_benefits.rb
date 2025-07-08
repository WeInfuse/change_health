# frozen_string_literal: true

module ChangeHealth
  module Response
    class EligibilityBenefits < Array
      def initialize(benefits)
        super(benefits.map { |benefit| ChangeHealth::Response::EligibilityBenefit.new(benefit) })
      end

      def where(**kwargs)
        self.class.new(self.select { |benefit| kwargs.all? { |k, v| benefit_matches?(benefit, k, v) } })
      end

      def where_not(**kwargs)
        self.class.new(reject { |benefit| kwargs.all? { |k, v| benefit_matches?(benefit, k, v) } })
      end

      def +(other)
        self.class.new(to_a + other.to_a)
      end

      def find_by(**kwargs)
        find { |benefit| kwargs.all? { |k, v| benefit[k].is_a?(Array) ? benefit[k].include?(v) : v == benefit[k] } }
      end

      def in_network
        where(inPlanNetworkIndicatorCode: 'Y')
      end

      ChangeHealth::Response::EligibilityBenefit::HELPERS.each do |key, types|
        types.each do |method, value|
          define_method("#{method}s") do
            where(key => value)
          end
        end
      end

      # rubocop:disable Metrics/BlockLength
      %w[family individual employee child employee_and_child].each do |method|
        define_method(method) do
          send("#{method}s")
        end

        co_types = %w[copayment coinsurance]
        remaining_types = %w[deductible out_of_pocket]
        date_types = %w[year remaining]

        co_types.each do |type_mod|
          method_name = "#{method}_#{type_mod}"

          define_method(method_name) do |**kwargs|
            send(method).send("#{type_mod}s").where(**kwargs).first
          end

          next unless 'copayment' == type_mod

          define_method(method_name.gsub('copayment', 'copay')) do |**kwargs|
            send(method_name, **kwargs)
          end
        end

        remaining_types.each do |type_mod|
          date_types.each do |time_mod|
            method_name = "#{method}_#{type_mod}_#{time_mod}"

            # rubocop:disable Layout/LineLength
            define_method(method_name) do |**kwargs|
              send(method).send("#{type_mod}s").send("#{time_mod}s").where(**kwargs).first || send(method).send("#{type_mod}s").where(**kwargs).first
            end
            # rubocop:enable Layout/LineLength

            if 'out_of_pocket' == type_mod
              define_method(method_name.gsub('out_of_pocket', 'oop')) do |**kwargs|
                send(method_name, **kwargs)
              end

              if 'year' == time_mod
                define_method(method_name.gsub('out_of_pocket', 'oop').gsub('year', 'total')) do |**kwargs|
                  send(method_name, **kwargs)
                end
              end
            end

            next unless 'year' == time_mod

            define_method(method_name.gsub('year', 'total')) do |**kwargs|
              send(method_name, **kwargs)
            end
          end
        end
      end
      # rubocop:enable Metrics/BlockLength

      alias oops out_of_pockets
      alias copays copayments

      private

      def benefit_matches?(benefit, key, value)
        return benefit_array_matches?(benefit[key], value) if benefit[key].is_a?(Array)

        return value.include?(benefit[key]) if value.is_a?(Array)

        medicare_benefit = benefit_medicare?(benefit, key, value) if benefit.medicare?

        medicare_benefit.nil? ? value == benefit[key] : medicare_benefit
      end

      def benefit_array_matches?(benefit_array, value)
        if value.is_a?(Array)
          value.any? do |possible_v|
            benefit_array.include?(possible_v)
          end
        else
          benefit_array.include?(value)
        end
      end

      def benefit_medicare?(benefit, key, value)
        if :inPlanNetworkIndicatorCode == key.to_sym
          return false == benefit.in_plan_network? if 'N' == value

          benefit.in_plan_network? if 'Y' == value
        elsif :coverageLevelCode == key.to_sym
          return false == benefit.individual? if EligibilityBenefit::INDIVIDUAL != value

          benefit.individual? if EligibilityBenefit::INDIVIDUAL == value
        end
      end
    end
  end
end
