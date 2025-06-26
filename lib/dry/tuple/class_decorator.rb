# frozen_string_literal: true

module Dry
  module Tuple
    # Pure class type decorator mixin.
    module ClassDecorator
      # @param input [Array]
      #   the result of {#coerce_tuple}
      # @return [self]
      # @abstract
      #   Redefine to handle input transformations. For example to splat input array.
      # @note
      #   Will be invoked on input that was passed thru tuple validation & coercion.
      def new_from_tuple(input)
        defined?(super) ? super(input) : new(input)
      end

      # @param input [Array<Mixed>]
      #   the result of {Types::Tuple#call}
      # @return [Array]
      #   coerced input
      # @note
      #   Will be invoked on input that was passed thru tuple validation & coercion.
      def coerce_tuple(input)
        defined?(super) ? super(input) : input
      end

      # @api private
      def call_safe(input, &block)
        if input.is_a?(self)
          input
        elsif input.is_a?(Array)
          resolve_tuple_safe(input, &block)
        else
          super(input, &block)
        end
      end

      # @api private
      def call_unsafe(input)
        if input.is_a?(self)
          input
        elsif input.is_a?(Array)
          resolve_tuple_unsafe(input)
        else
          super
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
  end
end
