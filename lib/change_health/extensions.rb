module ChangeHealth
  module Extensions
    module InNetworkW
      def in_network
        self.where(inPlanNetworkIndicatorCode: 'Y') + self.where(inPlanNetworkIndicatorCode: 'W')
      end
    end

    module InNetworkMissing
      def in_network
        self.where_not(inPlanNetworkIndicatorCode: 'N')
      end
    end

    module DeductiblesIgnoreSpecialistZero
      def deductibles
        super.where_not(serviceTypeCodes: '98', benefitAmount: '0')
      end
    end

    module CopaymentsIgnoreSpecialistZero
      def copayments
        super.where_not(serviceTypeCodes: '98', benefitAmount: '0')
      end
    end

    module CoinsurancesIgnoreSpecialistZero
      def coinsurances
        super.where_not(serviceTypeCodes: '98', benefitPercent: '0')
      end
    end

    module IndividualsAllNonFamily
      def individuals
        self.where_not(coverageLevelCode: 'FAM')
      end
    end
  end
end
