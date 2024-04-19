[![CircleCI](https://circleci.com/gh/WeInfuse/change_health.svg?style=svg)](https://circleci.com/gh/WeInfuse/change_health)

```
   ____ _                              _   _            _ _   _     
  / ___| |__   __ _ _ __   __ _  ___  | | | | ___  __ _| | |_| |__  
 | |   | '_ \ / _` | '_ \ / _` |/ _ \ | |_| |/ _ \/ _` | | __| '_ \ 
 | |___| | | | (_| | | | | (_| |  __/ |  _  |  __/ (_| | | |_| | | |
  \____|_| |_|\__,_|_| |_|\__, |\___| |_| |_|\___|\__,_|_|\__|_| |_|
                          |___/                                     
```

Ruby API wrapper for [Change Health](https://developers.changehealthcare.com/api)

# Installation

Add this line to your application's Gemfile:

```ruby
gem 'change_health'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install change_health

# Usage

## Setup

Make sure you're [configured](#configuration)!

## Eligibility
[Change Healthcare Eligibility Guide](https://developers.changehealthcare.com/eligibilityandclaims/docs)
```ruby
ChangeHealth::Request::Eligibility.ping # Test your connection

encounter  = ChangeHealth::Models::Eligibility::Encounter.new(date_of_service: Date.current, service_type_codes: ['98'])
provider   = ChangeHealth::Models::Eligibility::Provider.new(npi: '0123456789', last_name: 'Bobson', first_name: 'Bob')
subscriber = ChangeHealth::Models::Eligibility::Subscriber.new(member_id: '0000000000', first_name: 'johnOne', last_name: 'doeOne', date_of_birth: '18800102')

edata = ChangeHealth::Request::Eligibility.new(tradingPartnerServiceId: '000050', provider: provider, subscriber: subscriber, encounter: encounter).query

edata.raw # Raw Hash of JSON response
```

### Benefit(s) objects
Benefits extends Array and provides a query-like interface.

Benefit extends Hash and provides helpers for single-benefit.

```ruby
edata.benefits # Returns Benefits querying object (extends Array)

edata.benefits.individual # Only benefits matching the 'IND' identifier

edata.benefits.individual.in_network # 'IND' and in-plan-network = 'Y'

edata.benefits.individual(name: 'Co-Payment') # Manually finding "name" == "Co-Payment" in JSON
edata.benefits.individual(customParam: 'hi') # Filter on any params in the API combined with 'IND' type

edata.benefits.where(name: 'Co-Payment', code: 'B', benefitAmount: '30) # Generic 'where' api returns a Benefits querying object for chaining
edata.benefits.find_by(name: 'Co-Payment', code: 'B', benefitAmount: '30) # Generic 'find_by' api returns first object found
```

### Response

Response is EligibilityData object

```ruby
edata.response
#<HTTParty::Response:0x7fa354c1fbe8>

edata.response.ok?
# true

edata.individual_oop_remaining(service_code: '30')
# 1344.88

edata.raw == edata.response.parsed_response
# true
```

## Trading Partners
```ruby
# Query trading partners using a wildcard search
# Returns Array of ChangeHealth::Models::TradingPartner Objects
# Query params: term, service_name(default: 'Eligibility'), clearing_house(default: 'npd')
trading_partners = ChangeHealth::Request::TradingPartner.query("Aetna", service_name: 'Eligibility', clearing_house: 'dbq')

trading_partners.first.name
# "Aetna"

trading_partners.first.service_id
# "ABC123"
```

## Claim Submission

### Professional Claims
[Change Healthcare Professional Claim Submission Guide](https://developers.changehealthcare.com/eligibilityandclaims/docs/professional-claims-v3-getting-started)
```ruby
ChangeHealth::Request::Claim::Submission.ping # Test your connection

contact_information = ChangeHealth::Models::Claim::ContactInformation.new(
  name: "SUBMITTER CONTACT INFO",
  phone_number: "123456789"
)

submitter = ChangeHealth::Models::Claim::Submitter.new(
  organization_name: "REGIONAL PPO NETWORK",
  contact_information: contact_information
)

receiver = ChangeHealth::Models::Claim::Receiver.new(
  organization_name: "EXTRA HEALTHY INSURANCE"
)

address = ChangeHealth::Models::Claim::Address.new(
  address1: "123 address1",
  city: "city1",
  state: "wa",
  postalCode: "981010000"
)

subscriber = ChangeHealth::Models::Claim::Subscriber.new(
  member_id: "0000000001",
  payment_responsibility_level_code: "P",
  first_name: "johnone",
  last_name: "doetwo",
  gender: "M",
  date_of_birth: "02/01/1980",
  address: address
)

dependent = ChangeHealth::Models::Claim::Dependent.new(
  address: address,
  date_of_birth: "02/01/1980",
  first_name: "johnone",
  gender: "M",
  last_name: "doetwo",
  member_id: "0000000001",
  relationship_to_subscriber_code: "01"
)

provider = ChangeHealth::Models::Claim::Provider.new(
  address: address,
  employer_id: "000000000",
  first_name: "johnone",
  last_name: "doetwo",
  npi: "1760854442",
  provider_type: "BillingProvider"
)

diagnosis1 = ChangeHealth::Models::Claim::Diagnosis.new(
  diagnosis_type_code: "ABK",
  diagnosis_code: "S93401A"
)

diagnosis2 = ChangeHealth::Models::Claim::Diagnosis.new(
  diagnosis_type_code: "ABF",
  diagnosis_code: "S72044G"
)

service_line1 = ChangeHealth::Models::Claim::ServiceLine.new(
  service_date: "2018-05-14",
  professional_service: ChangeHealth::Models::Claim::ProfessionalService.new(
    line_item_charge_amount: "25",
    measurement_unit: "UN",
    procedure_code: "E0570",
    procedure_identifier: "HC",
    service_unit_count: "1",
    composite_diagnosis_code_pointers: {
      diagnosisCodePointers: ["1","2"]
    }
  )
)

service_line2 = ChangeHealth::Models::Claim::ServiceLine.new(
  service_date: "20180514",
  service_date_end: "20180514",
  professional_service: ChangeHealth::Models::Claim::ProfessionalService.new(
    line_item_charge_amount: "3.75",
    measurement_unit: "UN",
    procedure_code: "A7003",
    procedure_identifier: "HC",
    service_unit_count: "1",
    composite_diagnosis_code_pointers: {
      diagnosisCodePointers: ["1"]
    }
  )
)

claim_information = ChangeHealth::Models::Claim::ClaimInformation.new(
  benefits_assignment_certification_indicator: "Y",
  claim_charge_amount: "28.75",
  claim_filing_code: "CI",
  claim_frequency_code: "1",
  patient_control_number: "12345",
  place_of_service_code: "11",
  plan_participation_code: "A",
  release_information_code: "Y",
  signature_indicator: "Y",
  health_care_code_information: [diagnosis1, diagnosis2],
  service_lines: [service_line1, service_line2]
)

headers = {
  submitter_id: '111000',
  biller_id: '000111',
  username: '222333hey',
  password: 'builder1'
}

claim_submission = ChangeHealth::Request::Claim::Submission.new(
  claim_information: claim_information,
  dependent: dependent,
  headers: headers,
  pay_to_address: address,
  providers: [provider],
  receiver: receiver,
  submitter: submitter,
  subscriber: subscriber,
  trading_partner_service_id: "9496"
)

claim_submission_data = claim_submission.submission

validation = claim_submission.validation
```

### Institutional Claims
[Change Healthcare Institutional Claim Submission Guide](https://developers.changehealthcare.com/eligibilityandclaims/docs/institutional-claims-v1-api-getting-started)
```ruby
ChangeHealth::Request::Claim::Submission.ping(is_professional: false) # Test your connection

billing_pay_to_address_name = ChangeHealth::Models::Claim::BillingPayToAddressName.new(
  entity_type_qualifier: "2",
  address: address
)

claim_code_information = ChangeHealth::Models::Claim::ClaimCodeInformation.new(
  admission_source_code: "7",
  admission_type_code: "1",
  patient_status_code: "10"
)

other_diagnosis_information_list = [[
  ChangeHealth::Models::Claim::Diagnosis.new(
    other_diagnosis_code: "S72044G",
    qualifier_code: "ABF"
  ),
  ChangeHealth::Models::Claim::Diagnosis.new(
    other_diagnosis_code: "S72044H",
    qualifier_code: "ABF"
  )
]]

principal_diagnosis = ChangeHealth::Models::Claim::Diagnosis.new(
  principal_diagnosis_code: "S93401A",
  qualifier_code: "ABK"
)

service_line1 = ChangeHealth::Models::Claim::ServiceLine.new(
  assigned_number: "1",
  institutional_service: ChangeHealth::Models::Claim::InstitutionalService.new(
    line_item_charge_amount: "25",
    measurement_unit: "UN",
    procedure_code: "E0570",
    procedure_identifier: "HC",
    service_line_revenue_code: "X",
    service_unit_count: "1",
  )
)

service_line2 = ChangeHealth::Models::Claim::ServiceLine.new(
  assigned_number: "2",
  institutional_service: ChangeHealth::Models::Claim::InstitutionalService.new(
    line_item_charge_amount: "3.75",
    measurement_unit: "UN",
    procedure_code: "A7003",
    procedure_identifier: "HC",
    service_line_revenue_code: "Y",
    service_unit_count: "1",
  )
)

claim_information = ChangeHealth::Models::Claim::ClaimInformation.new(
  benefits_assignment_certification_indicator: "Y",
  claim_charge_amount: "28.75",
  claim_code_information: claim_code_information,
  claim_filing_code: "CI",
  claim_frequency_code: "1",
  other_diagnosis_information_list: other_diagnosis_information_list,
  patient_control_number: "12345",
  place_of_service_code: "11",
  plan_participation_code: "A",
  principal_diagnosis: principal_diagnosis,
  release_information_code: "Y",
  signature_indicator: "Y",
  service_lines: [service_line1, service_line2]
)

headers = {
  submitter_id: '111000',
  biller_id: '000111',
  username: '222333hey',
  password: 'builder1'
}

address = ChangeHealth::Models::Claim::Address.new(
  address1: "123 address1",
  city: "city1",
  state: "wa",
  postalCode: "981010000"
)

provider = ChangeHealth::Models::Claim::Provider.new(
  address: address,
  employer_id: "000000000",
  first_name: "johnone",
  last_name: "doetwo",
  npi: "1760854442",
  organization_name: "EXTRA HEALTHY INSURANCE",
  provider_type: "BillingProvider"
)

receiver = ChangeHealth::Models::Claim::Receiver.new(
  organization_name: "EXTRA HEALTHY INSURANCE"
)

contact_information = ChangeHealth::Models::Claim::ContactInformation.new(
  name: "SUBMITTER CONTACT INFO",
  phone_number: "123456789"
)

submitter = ChangeHealth::Models::Claim::Submitter.new(
  organization_name: "REGIONAL PPO NETWORK",
  contact_information: contact_information
)

subscriber = ChangeHealth::Models::Claim::Subscriber.new(
  member_id: "0000000001",
  payment_responsibility_level_code: "P",
  first_name: "johnone",
  last_name: "doetwo",
  gender: "M",
  date_of_birth: "02/01/1980",
  address: address
)

claim_submission = ChangeHealth::Request::Claim::Submission.new(
  claim_information: claim_information,
  headers: headers,
  providers: [provider],
  receiver: receiver,
  submitter: submitter,
  subscriber: subscriber,
  trading_partner_service_id: "9496",
  billing_pay_to_address_name: billing_pay_to_address_name
)

claim_supplemental_information = ChangeHealth::Models::Claim::ClaimSupplementalInformation.new(
  claim_control_number: 'claimControlNumber',
  demo_project_identifier: 'demoProjectIdentifier',
  prior_authorization_number: 'priorAuthorizationNumber',
  referral_number: 'referralNumber',
  report_information: 'reportInformation'
)

claim_submission_data = claim_submission.submission(is_professional: false)

validation = claim_submission.validation(is_professional: false)
```

## Claim Reports
[Change Healthcare Claim Responses and Reports Guide](https://developers.changehealthcare.com/eligibilityandclaims/docs/claims-responses-and-reports-getting-started)

### Get Reports
```ruby
ChangeHealth::Request::Claim::Report.ping # Test your connection

report_headers = {
  username: '111000john',
  password: 'WeInfuse1'
}

report_list = ChangeHealth::Request::Claim::Report.report_list(headers: report_headers)

report_list.report_names
# ["X3000000.XX", "R5000000.XY", "R5000000.XX", "X3000000.AB", "X3000000.AC", "X3000000.ZZ", "R5000000.XZ", "R5000000.YZ", "R5000000.WA", "R5000000.WB", "R5000000.WC"]

report0_edi = ChangeHealth::Request::Claim::Report.get_report(report_list.report_names.first, as_json_report: false)
# Report in edi format

report0_json = ChangeHealth::Request::Claim::Report.get_report(report_list.report_names.first, as_json_report: true)
# Report in json format

reports_json = report_list.report_names.map {|report_name| ChangeHealth::Request::Claim::Report.get_report(report_name, headers: report_headers)}
# all reports in json format

reports_edi = report_list.report_names.map {|report_name| ChangeHealth::Request::Claim::Report.get_report(report_name, as_json_report: false, headers: report_headers)}
# all reports in edi format
```

### Inspect Reports
Currently only works for json 277 reports and json 835 reports. Not for EDI reports

From a report, you can get an array of claims

#### Report 277

```ruby
report277_data = ChangeHealth::Request::Claim::Report.get_report("X3000000.AB", as_json_report: true)

report277_data.payer_name
# "PREMERA"

report277_data.report_creation_date
# Tue, 01 Dec 2020

claim277 = report277_data.claims.first
claim277.payer_name
# "PREMERA"

claim277.report_name
# "X3000000.AB"

claim277.patient_first_name
# "JOHNONE"

claim277.report_creation_date
# Tue, 01 Dec 2020

# Report 277 specific below
claim277.latest_status_category_codes
# ["F1"]

claim277.total_charge_amount
# "100"

claim277.procedure_codes
# ["97161"]
```

#### Report 835

```ruby
report835_data = ChangeHealth::Request::Claim::Report.get_report("R5000000.XY", as_json_report: true)

payment835 = report835_data.payments.first

payment835.payment_method_code
# "ACH"

payment835.total_actual_provider_payment_amount
# "2563.13"

claim835 = payment835.claims.first
claim835.payer_name
# "NATIONAL GOVERNMENT SERVICES, INC."

claim835.patient_first_name
# "JANE"

claim835.patient_member_id
# "7SL5RA7XR19"

claim835.report_creation_date
# Wed, 22 Apr 2020

claim835.procedure_codes
# ["21210", "21026", "21208", "30580"]

claim835.service_lines.map(&:line_item_charge_amount)
# ["3600", "1890", "1836", "1680"]

claim835.claim_status_code
# "19"
```

### Delete Reports
[Delete Endpoint FAQ](https://developers.changehealthcare.com/eligibilityandclaims/docs/claims-responses-and-reports-faq#delete-http-endpoint)

[Delete Endpoint API Reference](https://developers.changehealthcare.com/eligibilityandclaims/reference/delete_single_report_v2_reports__filename__delete)


```ruby
ChangeHealth::Request::Claim::Report.delete_report("R5000000.XY")
```

## Configuration

```ruby
ChangeHealth.configure do |c|
  c.client_id     = ENV['CHANGE_HEALTH_CLIENT_ID']
  c.client_secret = ENV['CHANGE_HEALTH_SECRET']
  c.grant_type    = 'client_credentials' # Defaults to client_credentials
  c.api_endpoint  = 'https://sandbox.apigw.changehealthcare.com' # Defaults to Change Health Sandbox endpoint
end
```

# Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

# Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/WeInfuse/change_health.
