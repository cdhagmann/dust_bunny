# frozen_string_literal: true

require_relative 'lib/dust_bunny/version'

Gem::Specification.new do |spec|
  spec.name          = 'dust_bunny'
  spec.version       = DustBunny::VERSION
  spec.authors       = ['Christopher Hagmann']
  spec.email         = ['cdhagmann@gmail.com']

  spec.summary       = 'A giant pile of lint'
  spec.description   = 'Configure and run all of the linters.'
  spec.homepage      = 'https://cdhagmann.com/dust_bunny'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/cdhagmann/dust_bunny'
  spec.metadata['changelog_uri'] = 'https://github.com/cdhagmann/dust_bunny'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'git'
  spec.add_dependency "thor"
  spec.add_dependency 'wasmer'

  spec.add_development_dependency 'amazing_print'
  spec.add_development_dependency 'aruba'
  spec.add_development_dependency 'cucumber'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rspec', '~> 3.2'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-performance'
  spec.add_development_dependency 'rubocop-rake'
  spec.add_development_dependency 'rubocop-rspec'
end
