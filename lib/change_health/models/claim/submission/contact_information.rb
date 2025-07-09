# frozen_string_literal: true

module ChangeHealth
  module Models
    module Claim
      class ContactInformation < Model
        property :email
        property :faxNumber, from: :fax_number
        property :name
        property :phoneNumber, from: :phone_number
      end
    end
  end
end
