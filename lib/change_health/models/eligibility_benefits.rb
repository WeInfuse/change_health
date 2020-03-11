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

      def individual_copayment_visit(**kwargs)
        self.individual.copayments.visits.where(kwargs).first
      end

      def individual_out_of_pocket_remaining(**kwargs)
        self.individual.out_of_pockets.remainings.where(kwargs).first
      end

      def individual_out_of_pocket_total(**kwargs)
        self.individual.out_of_pockets.years.where(kwargs).first
      end

      def individual_deductible_remaining(**kwargs)
        self.individual.deductibles.remainings.where(kwargs).first
      end

      def individual_deductible_total(**kwargs)
        self.individual.deductibles.years.where(kwargs).first
      end

      alias_method :oops, :out_of_pockets
      alias_method :copays, :copayments
      alias_method :individual_copay_visit, :individual_copayment_visit
      alias_method :individual_oop_remaining, :individual_out_of_pocket_remaining
      alias_method :individual_oop_total, :individual_out_of_pocket_total
      alias_method :individual, :individuals
      alias_method :employee, :employees
      alias_method :child, :childs

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
