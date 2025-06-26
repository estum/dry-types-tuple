# frozen_string_literal: true

require "dry-struct"

module Dry
  module Tuple
    # {Dry::Struct} abstract subclass extended with {Dry::Types::Struct::ClassInterface}
    #
    # @example Usage
    #   class Ambivalent < Dry::Tuple::Struct
    #     attribute :left, Dry::Types['coercible.string']
    #     attribute :right, Dry::Types['coercible.string']
    #
    #     # set key order
    #     auto_tuple :left, :right
    #   end
    #
    #   class AmbivalentButPrefer < Ambivalent
    #     attribute :prefer, Dry::Types['coercible.symbol'].enum(:left, :right)
    #     auto_tuple :prefer
    #   end
    class Struct < Dry::Struct
      abstract

      # Extracted due to make it possible to use this feature within {Dry::Struct} classes.
      # @example extending Dry::Struct subclass
      #
      #   class SomeStruct < Dry::Struct
      #     attribute :some, Types::Integer
      #     attribute :with, Types::Hash
      #
      #     extend ::Dry::Tuple::Struct::ClassInterface
      #     auto_tuple :some, :with
      #   end
      module ClassInterface
        include ClassDecorator

        # Merges the given keys into the #{keys_order} and redefines the +tuple+ of class.
        # @param keys [Array<Symbol>]
        # @return [void]
        def auto_tuple(*keys)
          keys_order(keys_order | keys)
          index = schema.keys.map { |t| [t.name, t.type] }.to_h
          tuple Dry::Types::Tuple.coerce(index.values_at(*keys_order))
        end

        # Constructs a hash of struct attributes from the given array by zipping within {#keys_order}.
        # @param input [Array<Any>]
        # @return [Hash]
        def coerce_tuple(input)
          keys_order.zip(input).to_h
        end

        # @return [Dry::Types::Result]
        def try(input, &block)
          if input.is_a?(::Array)
            tuple.try(input, &block)
          else
            super(input, &block)
          end
        end

        # @api private
        def self.extended(base)
          base.defines :tuple, coerce: TypeCoercer
          base.defines :keys_order, type: Dry::Types['array<symbol>']
          base.keys_order EMPTY_ARRAY
          super
        end
      end

      extend ClassInterface
    end
  end
end
