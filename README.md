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
trading_partners = ChangeHealth::Request::TradingPartner.query("Aetna")

trading_partners.first.name
# "Aetna"

trading_partners.first.service_id
# "ABC123"
```

## Claim Submission
[Change Healthcare Claim Submission Guide](https://developers.changehealthcare.com/eligibilityandclaims/docs/professional-claims-v3-getting-started)
```ruby
ChangeHealth::Request::Claim::Submission.ping # Test your connection

contact_information = { name: "SUBMITTER CONTACT INFO", phoneNumber: "123456789"}
claim_submitter = ChangeHealth::Models::Claim::Submitter.new(
  organization_name: "REGIONAL PPO NETWORK",
  contact_information: contact_information
)

receiver = { organizationName: "EXTRA HEALTHY INSURANCE"}
address = {
  "address1": "123 address1",
  "city": "city1",
  "state": "wa",
  "postalCode": "981010000"
}
subscriber = ChangeHealth::Models::Claim::Subscriber.new(
  member_id: "0000000001",
  payment_responsibility_level_code: "P",
  first_name: "johnone",
  last_name: "doetwo",
  gender: "M",
  date_of_birth: "02/01/1980",
  address: address
)
provider = ChangeHealth::Models::Claim::Provider.new(
  address: address,
 employer_id: "000000000",
 first_name: "johnone",
 last_name: "doetwo",
 npi: "1760854442",
 provider_type: "BillingProvider"
)

health_care_code_information1 = {
  "diagnosisTypeCode": "ABK",
  "diagnosisCode": "S93401A"
}
health_care_code_information2 = {
  "diagnosisTypeCode": "ABF",
  "diagnosisCode": "S72044G"

}
service_line1 = ChangeHealth::Models::Claim::ServiceLine.new(
  service_date: "2018-05-14",
  professional_service: {
    "procedureIdentifier": "HC",
    "lineItemChargeAmount": "25",
    "procedureCode": "E0570",
    "measurementUnit": "UN",
    "serviceUnitCount": "1",
    "compositeDiagnosisCodePointers": {
      "diagnosisCodePointers": ["1","2"]
    }
  }
)
service_line2 = ChangeHealth::Models::Claim::ServiceLine.new(
  service_date: "20180514",
  professional_service: {
    "procedureIdentifier": "HC",
    "lineItemChargeAmount": "3.75",
    "procedureCode": "A7003",
    "measurementUnit": "UN",
    "serviceUnitCount": "1",
    "compositeDiagnosisCodePointers": {
      "diagnosisCodePointers": ["1"]
    }
  }
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
  health_care_code_information: [health_care_code_information1, health_care_code_information2],
  service_lines: [service_line1, service_line2]
)

professional_headers = {
  submitter_id: '111000',
  biller_id: '000111',
  username: '222333hey',
  password: 'builder1'
}

claim_submission = ChangeHealth::Request::Claim::Submission.new(
  trading_partner_service_id: "9496",
  submitter: claim_submitter,
  receiver: receiver,
  subscriber: subscriber,
  providers: [provider],
  claim_information: claim_information,
  headers: professional_headers
)

claim_submission_data = claim_submission.submission

validation = claim_submission.validation
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
report_277_data = ChangeHealth::Request::Claim::Report.get_report("X3000000.AB", as_json_report: true)

report_277_data.payer_name
# "PREMERA"

report_277_data.report_creation_date
# Tue, 01 Dec 2020

claim_277 = report_277_data.claims.first
claim_277.payer_name
# "PREMERA"

claim_277.patient_first_name
# "JOHNONE"

claim_277.report_creation_date
# Tue, 01 Dec 2020

# Report 277 specific below
claim_277.latest_status_category_codes
# ["F1"]

claim_277.total_charge_amount
# "100"

claim_277.procedure_codes
# ["97161"]
```

#### Report 835

```ruby
report_835_data = ChangeHealth::Request::Claim::Report.get_report("R5000000.XY", as_json_report: true)

report_835_data.payment_method_code
# "ACH"

report_835_data.total_actual_provider_payment_amount
# "2563.13"

claim_835 = report_835_data.claims.first
claim_835.payer_name
# "NATIONAL GOVERNMENT SERVICES, INC."

claim_835.patient_first_name
# "JANE"

claim_835.report_creation_date
# Wed, 22 Apr 2020

claim_835.procedure_codes
# ["21210", "21026", "21208", "30580"]

claim_835.service_lines.map(&:line_item_charge_amount)
# ["3600", "1890", "1836", "1680"]
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

Bug reports and pull requests are welcome on GitHub at https://github.com/WeInfuse/change\_health.
