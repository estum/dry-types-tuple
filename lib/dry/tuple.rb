# frozen_string_literal: true

require 'dry/types/tuple'

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
    # Pure class type decorator mixin.
    module ClassDecorator
      include Types::Decorator

      # @return [@tuple]
      def type
        @tuple
      end

      # @param input [Array] the result of {#coerce_tuple}
      # @return [self]
      # @abstract
      #   It is designed to be redefined for example to splat arguments on constructor.
      # @note
      #   Will be invoked on input that was passed thru tuple validation & coercion.
      def new_from_tuple(input)
        defined?(super) ? super(input) : new(input)
      end

      # @param input [Array] the result of tuple#call
      # @return [Array] coerced input
      # @note
      #   Will be invoked on input that was passed thru tuple validation & coercion.
      def coerce_tuple(input)
        defined?(super) ? super(input) : input
      end

      # @api private
      def call_safe(input, &block)
        if defined?(super)
          resolve_tuple_safe(input) { |output| super(output) }
        elsif input.is_a?(self)
          input
        else
          resolve_tuple_safe(input, &block)
        end
      end

      # @api private
      def call_unsafe(input)
        if defined?(super)
          resolve_tuple_safe(input) { |output| super(output) }
        elsif input.is_a?(self)
          input
        else
          resolve_tuple_unsafe(input)
        end
      end

      private

      # @api private
      def resolve_tuple_safe(input)
        input = tuple.call_safe(input) do |output = input|
          output = yield(output) if block_given?
          return output
        end
        new_from_tuple(coerce_tuple(input))
      end

      # @api private
      def resolve_tuple_unsafe(input)
        input = tuple.call_unsafe(input)
        new_from_tuple(coerce_tuple(input))
      end
    end

    module HookExtendObject
      # Makes the module's features to be prepended instead of appended to the target class when extended.
      # Also defines the `tuple` class attribute.
      # @api private
      private def extend_object(base)
        base.singleton_class.prepend(self)
        base.defines :tuple
      end
    end

    module ClassInterface
      include Core::ClassAttributes
      include Types::Type
      include Types::Builder
      include ClassDecorator
      extend HookExtendObject
    end

    # Extracted due to make it possible to use this feature within {Dry::Struct} classes.
    # @example extending Dry::Struct subclass
    #
    #   class SomeStruct < Dry::Struct
    #     attribute :some, Types::Integer
    #     attribute :with, Types::Hash
    #     extend ::Dry::Tuple::StructClassInterface
    #     auto_tuple :some, :with
    #   end
    module StructClassInterface
      include ClassDecorator
      extend HookExtendObject

      class << self
        private def extend_object(base)
          super
          base.defines :keys_order
          base.keys_order []
        end
      end

      def auto_tuple(*keys)
        keys_order(keys_order | keys)
        index = schema.keys.map { |t| [t.name, t.type] }.to_h
        tuple Dry::Types::Tuple.build_unsplat(index.values_at(*keys_order))
      end

      def coerce_tuple(input)
        keys_order.zip(input).to_h
      end
    end
  end
end
