[![CircleCI](https://circleci.com/gh/WeInfuse/change_health.svg?style=svg)](https://circleci.com/gh/WeInfuse/change_health)

# Change Health
Ruby API wrapper for [Change Health](https://developers.changehealthcare.com/api)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'change_health'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install change_health

## Usage

### Setup

Make sure you're [configured](#configuration)!

### Eligibility
[Change Healthcare Eligibility Guide](https://developers.changehealthcare.com/eligibilityandclaims/docs)
```ruby
ChangeHealth::Models::Eligibility.ping # Test your connection

encounter  = ChangeHealth::Models::Encounter.new(date_of_service: Date.current, service_type_codes: ['98'])
provider   = ChangeHealth::Models::Provider.new(npi: '0123456789', last_name: 'Bobson', first_name: 'Bob')
subscriber = ChangeHealth::Models::Subscriber.new(member_id: '0000000000', first_name: 'johnOne', last_name: 'doeOne', date_of_birth: '18800102')

edata = ChangeHealth::Models::Eligibility.new(tradingPartnerServiceId: '000050', provider: provider, subscriber: subscriber, encounter: encounter).query

edata.raw # Raw Hash of JSON response
```

#### Benefit(s) objects
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

#### Response

Response is EligibilityData object

```ruby
edata.response
#<HTTParty::Response:0x7fa354c1fbe8>

edata.response.ok?
true

edata.individual_oop_remaining(service_code: '30')
1344.88

edata.raw == edata.response.parsed_response
true
```

### Trading Partners
```ruby
# Query trading partners using a wildcard search
# Returns Array of ChangeHealth::Models::TradingPartner Objects
trading_partners = ChangeHealth::Request::TradingPartner.query("Aetna")

trading_partners.first.name
"Aetna"

trading_partners.first.service_id
"ABC123"
```

### Claim Submission
[Change Healthcare Claim Submission Guide](https://developers.changehealthcare.com/eligibilityandclaims/docs/professional-claims-v3-getting-started)
```ruby
ChangeHealth::Models::Claim::Submission.ping # Test your connection

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


claim_submission = ChangeHealth::Models::Claim::Submission.new(
  trading_partner_service_id: "9496",
  submitter: claim_submitter,
  receiver: receiver,
  subscriber: subscriber,
  providers: [provider],
  claim_information: claim_information
)

claim_submission_data = claim_submission.submission
```

### Configuration

```ruby
ChangeHealth.configure do |c|
  c.client_id     = ENV['CHANGE_HEALTH_CLIENT_ID']
  c.client_secret = ENV['CHANGE_HEALTH_SECRET']
  c.grant_type    = 'bob' # Defaults to client_credentials
  c.api_endpoint  = 'http://hello.com' # Defaults to Change Health Sandbox endpoint
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/WeInfuse/change\_health.
