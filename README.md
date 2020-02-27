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
```

### Response

The response object is a base `ChangeHealth::Models::Model` class.

With the HTTParty response object
```ruby
response.response
#<HTTParty::Response:0x7fa354c1fbe8>

response.response.ok?
true
```

And any `Model` objects that were returned
```ruby
```

### Configuration

```ruby
ChangeHealth.configure do |c|
  c.client_id     = ENV['CHANGE_HEALTH_CLIENT_ID']
  c.client_secret = ENV['CHANGE_HEALTH_SECRET']
  c.grant_type    = 'bob' # Defaults to client_credentials
  c.api_endpoint = 'http://hello.com' # Defaults to Change Health Sandbox endpoint
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/WeInfuse/change\_health.
