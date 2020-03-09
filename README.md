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

```ruby
ChangeHealth::Models::Eligibility.ping # Test your connection

encounter  = ChangeHealth::Models::Encounter.new(date_of_service: Date.current, service_type_codes: ['98'])
provider   = ChangeHealth::Models::Provider.new(npi: '0123456789', last_name: 'Bobson', first_name: 'Bob')
subscriber = ChangeHealth::Models::Subscriber.new(member_id: '0000000000', first_name: 'johnOne', last_name: 'doeOne', date_of_birth: '18800102')

edata = ChangeHealth::Models::Eligibility.new(tradingPartnerServiceId: '000050', provider: provider, subscriber: subscriber, encounter: encounter).query
```

### Benefit(s) objects
```
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
true

edata.individual_oop_remaining(service_code: '30')
1344.88

edata.raw == edata.response.parsed_response
true
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
