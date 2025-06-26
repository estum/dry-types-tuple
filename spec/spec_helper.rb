# frozen_string_literal: true

require_relative "support/coverage"
require_relative "support/warnings"
require_relative "support/rspec_options"

require "pathname"
require "dry/types"
require "dry/types/spec/types"
require "dry/inflector"
require "dry-types-tuple"

SPEC_ROOT = Pathname(__dir__)

require_relative "support/dry_types_printer_fix"

Dir[SPEC_ROOT.join("shared/**/*.rb")].sort.each(&method(:require))

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.before do
    @types = Dry::Types.container._container.keys
  end

  Module.new do
    def inflector = @inflector ||= Dry::Inflector.new
    def undefined = Dry::Core::Constants::Undefined
  end.then do |shorthands|
    config.extend shorthands
    config.include shorthands
  end
end
