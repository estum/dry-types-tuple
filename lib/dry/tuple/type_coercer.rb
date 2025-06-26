# frozen_string_literal: true

module Dry
  module Tuple
    module TypeCoercer
      module_function

      # @overload Coercer.call(array)
      #   @param array [Array<Mixed>]
      # @overload Coercer.call(input)
      #   @param tuple [Dry::Types::Tuple]
      # @overload Coercer.call(type)
      #   @param type [Dry::Types::Constrained]
      # @example Usage
      #   Dry::Types::Tuple::Coercer.([Dry::Types['any'], Dry::Types['string']])
      def call(input, returns: Undefined)
        case input when Array
          Dry::Types::Tuple.coerce(input)
        when Dry::Types::Tuple
          Undefined.default(returns, input)
        when Dry::Types::Constrained
          call(input.type, returns: input)
        when NilClass
          Dry::Types['nominal.tuple']
        end
      end

      # @see Tuple.coerce
      # @example Usage
      #   Dry::Types::Tuple::Coercer[Dry::Types['any'], Dry::Types['string']]
      def [](*input, **opts)
        call(input, **opts)
      end
    end
  end
end
