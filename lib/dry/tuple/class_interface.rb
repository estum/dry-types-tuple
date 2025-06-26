# frozen_string_literal: true

require "dry/core/class_attributes"
require "dry/types/type"
require "dry/types/builder"
require "dry/types/decorator"

module Dry
  module Tuple
    # Universal class interface
    # @example Usage
    #   class SomeClass
    #     extend Dry::Tuple::ClassInterface
    #     tuple [Dry::Types['coercible.integer'], Dry::Types['string']]
    #
    #     def initialize(a, b)
    #       @a, @b = a, b
    #     end
    #   end
    module ClassInterface
      include Dry::Core::ClassAttributes
      include Dry::Types::Type
      include Dry::Types::Builder
      include Dry::Types::Decorator
      include ClassDecorator

      # @return [Dry::Types::Tuple]
      def type = @tuple

      # @!method tuple()
      #   @overload tuple(input)
      #     @param input [Mixed]
      #     @see TypeCoercer#call
      #   @overload tuple()
      #     @return [Dry::Types::Tuple]

      # @api private
      def self.extended(base)
        base.defines :tuple, coerce: TypeCoercer
        super
      end
    end
  end
end
