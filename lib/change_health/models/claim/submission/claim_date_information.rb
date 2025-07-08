# frozen_string_literal: true

module ChangeHealth
  module Models
    module Claim
      class ClaimDateInformation < Model
        property :admissionDateAndHour, from: :admission_date_and_hour
        property :dischargeHour, from: :discharge_hour
        property :repricerReceivedDate, from: :repricer_received_date
        property :statementBeginDate, from: :statement_begin_date
        property :statementEndDate, from: :statement_end_date
      end
    end
  end
end
