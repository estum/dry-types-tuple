# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in dry-types-tuple.gemspec
gemspec

gem "rake", "~> 13.0"

group :test do
  gem "simplecov", require: false, platforms: :ruby
  gem "simplecov-cobertura", require: false, platforms: :ruby
  gem "rspec"
  gem "warning"
  gem "rspec-instafail", require: false
  gem "dry-initializer", require: false
  gem "dry-inflector"
  gem "dry-struct"
end

group :tools do
  gem "rubocop", "~> 1.40.0"
  gem "byebug"
end

group :console do
  gem "pry"
end