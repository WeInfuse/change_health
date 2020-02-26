lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'change_health/version'

Gem::Specification.new do |spec|
  spec.name          = 'change_health'
  spec.version       = ChangeHealth::VERSION
  spec.authors       = ['Mike Crockett']
  spec.email         = ['mike.crockett@weinfuse.com']

  spec.summary       = 'Ruby wrapper for the ChangeHealth API'
  spec.homepage      = 'https://github.com/WeInfuse/change_health'

  # Prevent pushing this gem to RubyGems.org.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match?(%r{^(test|spec|features|bin|helpers|)/}) || f.match?(%r{^(\.[[:alnum:]]+)})
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.licenses      = ['MIT']

  spec.add_dependency 'httparty', '~> 0.17'
  spec.add_dependency 'hashie', '~> 3.5'
  spec.add_development_dependency 'bundler', '>=1', '<3'
  spec.add_development_dependency 'byebug', '~> 11'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'webmock', '~> 3.1'
  spec.add_development_dependency 'yard', '~> 0.9'
end
