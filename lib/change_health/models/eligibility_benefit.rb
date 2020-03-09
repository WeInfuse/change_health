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

      def individual
        self.where(coverageLevelCode: ChangeHealth::Models::EligibilityBenefit::INDIVIDUAL)
      end

      def in_network
        self.where(inPlanNetworkIndicatorCode: 'Y')
      end

      %w(visit year remaining).each do |method|
        define_method("#{method}s") do
          self.where(timeQualifierCode: Object.const_get("ChangeHealth::Models::EligibilityBenefit::#{method.upcase}"))
        end
      end

      %w(out_of_pocket copayment coinsurance).each do |method|
        define_method("#{method}s") do
          self.where(code: Object.const_get("ChangeHealth::Models::EligibilityBenefit::#{method.upcase}"))
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

      alias_method :oops, :out_of_pockets
      alias_method :copays, :copayments
      alias_method :individual_copay_visit, :individual_copayment_visit
      alias_method :individual_oop_remaining, :individual_out_of_pocket_remaining
      alias_method :individual_oop_total, :individual_out_of_pocket_total

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

    class EligibilityBenefit < Hash
      include Hashie::Extensions::MergeInitializer
      include Hashie::Extensions::IndifferentAccess

      OUT_OF_POCKET = 'G'
      COPAYMENT     = 'B'
      COINSURANCE   = 'A'
      NON_COVERED   = 'I'

      INDIVIDUAL    = 'IND'
      CHILD         = 'CHD'

      VISIT         = '27'
      YEAR          = '23'
      REMAINING     = '29'

      %w(individual child).each do |coverage_level|
        define_method("#{coverage_level}?") do
          Object.const_get("ChangeHealth::Models::EligibilityBenefit::#{coverage_level.upcase}") == self['coverageLevelCode']
        end
      end

      %w(visit year remaining).each do |time_qualifier|
        define_method("#{time_qualifier}?") do
          Object.const_get("ChangeHealth::Models::EligibilityBenefit::#{time_qualifier.upcase}") == self['timeQualifier']
        end
      end

      %w(out_of_pocket copayment coinsurance non_covered).each do |type|
        define_method("#{type}?") do
          Object.const_get("ChangeHealth::Models::EligibilityBenefit::#{type.upcase}") == self['code']
        end
      end

      %w(benefitAmount benefitPercent).each do |amount_method|
        define_method("#{amount_method}") do
          format_amount(amount_method)
        end
      end

      def in_plan_network?
        return 'Y' == self[:inPlanNetworkIndicatorCode]
      end
      alias_method :in_plan?, :in_plan_network?
      alias_method :in_network?, :in_plan_network?

      def amount
        self.coinsurance? ? self.benefitPercent : self.benefitAmount
      end

      def services 
        self['serviceTypeCodes']&.each_with_index&.map {|stc, i| [stc, self['serviceTypes']&.at(i)]} || []
      end

      private
      def format_amount(key)
        amt = self[key]
        amt = amt.to_f unless amt.nil?
      end
    end
  end
end
