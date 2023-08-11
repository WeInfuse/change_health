module ChangeHealth
  module Models
    module Claim
      class ReportInformation < Model
        property :attachmentControlNumber, from: :attachment_control_number
        property :attachmentReportTypeCode, from: :attachment_report_type_code
        property :attachmentTransmissionCode, from: :attachment_transmission_code
      end
    end
  end
end
