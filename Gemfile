source 'https://rubygems.org'

# Specify your gem's dependencies in heart_seed.gemspec
gemspec

if Gem::Version.create(RUBY_VERSION) < Gem::Version.create("2.2.2")
  # NOTE: rails 5+ requires Ruby 2.2.2+
  gem "activerecord", "< 5.0.0"
  gem "activesupport", "< 5.0.0"

  # https://github.com/rails/rails/blob/v4.2.11.1/activerecord/lib/active_record/connection_adapters/sqlite3_adapter.rb#L5
  gem "sqlite3", "~> 1.3.6"

elsif Gem::Version.create(RUBY_VERSION) < Gem::Version.create("2.5.0")
  # NOTE: rails 6+ requires Ruby 2.5.0+
  gem "activerecord", "< 6.0.0"
  gem "activesupport", "< 6.0.0"

  # https://github.com/rails/rails/blob/v5.2.3/activerecord/lib/active_record/connection_adapters/sqlite3_adapter.rb
  gem "sqlite3", "~> 1.3.6"

else
  # FIXME: Support activerecord 6.1+
  gem "activerecord", "< 6.1.0"
  gem "activesupport", "< 6.1.0"

  # https://github.com/rails/rails/blob/v6.0.0/activerecord/lib/active_record/connection_adapters/sqlite3_adapter.rb#L13
  gem "sqlite3", "~> 1.4"
end

if Gem::Version.create(RUBY_VERSION) < Gem::Version.create("2.5.0")
  # NOTE: unparser v0.3.0+ requires Ruby 2.5+
  gem "unparser", "< 0.3.0"
end
