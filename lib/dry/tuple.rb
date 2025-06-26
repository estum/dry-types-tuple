# frozen_string_literal: true

require "dry/tuple/version"
require "zeitwerk"
require "dry/core"

module Dry
  # The namespace contains mixins for class decoration with tuple type.
  # The interfaces provide a way to use a tuple in constructors to match proper class by input.
  # The behaviour is similar to the one provided by `Dry::Struct::ClassInterface` and
  # allows to combine classes into sums but with positional input validation & coercion.
  #
  # @example Splat input
  #   class Example
  #     extend Dry::Tuple::ClassInterface
  #     tuple Types.Tuple(Types::Integer, Types::String)
  #
  #     def initializer(a1, a2)
  #       # ...
  #     end
  #
  #     def self.new_from_tuple(input)
  #       new(*input)
  #     end
  #   end
  module Tuple
    include Dry::Core::Constants

    # rubocop:disable Metrics/MethodLength

    # @api private
    def self.loader
      @loader ||=
        ::Zeitwerk::Loader.new.tap do |loader|
          root = ::File.expand_path("..", __dir__)
          warn root
          loader.tag = "dry-types-tuple"
          loader.inflector = ::Zeitwerk::GemInflector.new("#{root}/dry-types-tuple.rb")
          loader.push_dir root
          loader.ignore \
            "#{root}/dry-types-tuple.rb",
            "#{root}/dry/types",
            # "#{root}/dry/tuple.rb",
            "#{root}/dry/tuple/{struct,version}.rb"

          if defined?(Pry)
            loader.log!
            loader.enable_reloading
          end
        end
    end

    # rubocop:enable Metrics/MethodLength

    loader.setup
  end
end