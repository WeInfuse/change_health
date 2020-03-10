module ChangeHealth
  module Models
    class EligibilityBenefit < Hash
      include Hashie::Extensions::MergeInitializer
      include Hashie::Extensions::IndifferentAccess

      OUT_OF_POCKET = 'G'
      COPAYMENT     = 'B'
      COINSURANCE   = 'A'
      NON_COVERED   = 'I'
      DEDUCTIBLE    = 'C'

      INDIVIDUAL    = 'IND'
      CHILD         = 'CHD'
      EMPLOYEE      = 'EMP'

      VISIT         = '27'
      YEAR          = '23'
      REMAINING     = '29'

      CODES = {
        out_of_pocket: OUT_OF_POCKET,
        copayment: COPAYMENT,
        coinsurance: COINSURANCE,
        non_covered: NON_COVERED,
        deductible: DEDUCTIBLE
      }
      COVERAGES = {
        individual: INDIVIDUAL,
        child: CHILD,
        employee: EMPLOYEE
      }
      TIMEFRAMES = {
        visit: VISIT,
        year: YEAR,
        remaining: REMAINING
      }
      HELPERS = {
        timeQualifierCode: TIMEFRAMES,
        coverageLevelCode: COVERAGES,
        code: CODES
      }
        
      HELPERS.each do |key, types|
        types.each do |method, value|
          define_method("#{method}?") do
            value == self[key]
          end
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
