# frozen_string_literal: true

module ChangeHealth
  module Extensions
    module InNetworkW
      def in_network
        where(inPlanNetworkIndicatorCode: 'Y') + where(inPlanNetworkIndicatorCode: 'W')
      end
    end

    module InNetworkMissing
      def in_network
        where_not(inPlanNetworkIndicatorCode: 'N')
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
        where_not(coverageLevelCode: 'FAM')
      end
    end
  end
end
