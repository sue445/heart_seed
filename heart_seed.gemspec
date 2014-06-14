# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'heart_seed/version'

Gem::Specification.new do |spec|
  spec.name          = "heart_seed"
  spec.version       = HeartSeed::VERSION
  spec.authors       = ["sue445"]
  spec.email         = ["sue445@sue445.net"]
  spec.summary       = %q{TODO: Write a short summary. Required.}
  spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = "https://github.com/sue445/heart_seed"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", ">= 3.0.0"
  spec.add_dependency "activerecord", ">= 3.0.0"
  spec.add_dependency "activerecord-import"
  spec.add_dependency "roo", "~> 1.13.2"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "3.0.0"
  spec.add_development_dependency "rspec-parameterized"
  spec.add_development_dependency "rspec-its"
  spec.add_development_dependency "rspec-collection_matchers"
  spec.add_development_dependency "yard"
  # spec.add_development_dependency "database_rewinder"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-remote"
  spec.add_development_dependency "pry-nav"
  spec.add_development_dependency "rake_shared_context"
  spec.add_development_dependency "codeclimate-test-reporter"
end

