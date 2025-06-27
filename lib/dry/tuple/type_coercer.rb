# frozen_string_literal: true

module Dry
  module Tuple
    module TypeCoercer
      module_function

      # @overload TypeCoercer.call(array)
      #   @param array [Array<Mixed>]
      # @overload TypeCoercer.call(input)
      #   @param tuple [Dry::Types::Tuple]
      # @overload TypeCoercer.call(type)
      #   @param type [Dry::Types::Constrained]
      # @example Usage
      #   Dry::Tuple::TypeCoercer.([Dry::Types['any'], Dry::Types['string']])
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
      #   Dry::Tuple::TypeCoercer[Dry::Types['any'], Dry::Types['string']]
      def [](*input, **opts)
        call(input, **opts)
      end
    end
  end
end
