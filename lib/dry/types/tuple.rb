# frozen_string_literal: true

module Dry
  module Types
    # @example
    #   Types::ServiceArgs = Types.Tuple(
    #     Types::Params::Symbol,                                # --- positional types
    #     [Types::Params::Integer | Types::Coercible::String]   # --- [type for the rest items]
    #   )
    #   Types::ServiceArgs[['thumb', '300', '300', 'sample']]
    #   # => [:thumb, 300, 300, "sample"]
    class Tuple < Array
      # Build a tuple type.
      #
      # @overload Tuple.build(*fixed_types, rest_type)
      #   @param [Array<Dry::Types::Type>] fixed_types
      #   @param [Array(Dry::Types::Type)] rest_type
      # @see build_index
      # @return [Dry::Types::Tuple]
      def self.build(*types)
        build_unsplat(types)
      end

      # @api private
      def self.build_unsplat(types)
        new(::Array, types_index: build_index(types))
      end

      # Prepares types index for the Tuple
      # @param [Array<Dry::Types::Type>] types
      # @see extract_rest
      # @return [Dry::Core::Constants::Undefined, Dry::Types::Type]
      def self.build_index(types)
        rest_type = extract_rest(types)
        types_index = ::Hash[types.size.times.zip(types)]
        types_index.default = Undefined.default(rest_type, nil)
        types_index
      end

      # Extracts and unwraps the rest type
      # @param [Array<Dry::Types::Type>] types
      # @return [Dry::Core::Constants::Undefined, Dry::Types::Type]
      def self.extract_rest(types)
        if !types[-1].is_a?(::Array)
          return Undefined
        end

        if types[-1].size > 1
          raise ArgumentError, "rest_type should be an Array with single element to apply to the rest of items: #{types[-1]}"
        end

        types.pop[0]
      end

      def initialize(_primitive, types_index: EMPTY_HASH, meta: EMPTY_HASH)
        super(_primitive, types_index: types_index, meta: meta)
      end

      # @see Tuple.build
      # @return [Dry::Types::Tuple]
      def of(*types)
        with(types_index: self.class.build_index(types))
      end

      # @return [Hash]
      #
      # @api public
      def types_index
        options[:types_index]
      end

      # @return [Array<Type>]
      #
      # @api public
      def fixed_types
        options[:types_index].values
      end

      # @return [Type]
      #
      # @api public
      def rest_type
        options[:types_index].default
      end

      # @return [String]
      #
      # @api public
      def name
        "Tuple"
      end

      # @param [Array] tuple
      #
      # @return [Array]
      #
      # @api private
      def call_unsafe(tuple)
        try(tuple) { |failure|
          raise MapError, failure.error.message
        }.input
      end

      # @param [Array] tuple
      #
      # @return [Array]
      #
      # @api private
      def call_safe(tuple)
        try(tuple) { return yield }.input
      end

      # @param [Array] tuple
      #
      # @return [Result]
      #
      # @api public
      def try(tuple)
        result = coerce(tuple)
        return result if result.success? || !block_given?

        yield(result)
      end

      # Build a lax type
      #
      # @return [Lax]
      #
      # @api public
      def lax
        lax_types_index = types_index.transform_values(&:lax)
        Lax.new(Tuple.new(primitive, **options, types_index: lax_types_index, meta: meta))
      end

      # @param meta [Boolean] Whether to dump the meta to the AST
      #
      # @return [Array] An AST representation
      #
      # @api public
      def to_ast(meta: true)
        structure = [*fixed_types.map { |type| type.to_ast(meta: true) }]
        structure << [rest_type.to_ast(meta: true)] unless rest_type.nil?
        structure << meta ? self.meta : EMPTY_HASH
        [:tuple, structure]
      end

      # @return [Boolean]
      #
      # @api public
      def constrained?
        rest_type&.constrained? || options[:types_index].each_value.any?(&:constrained?)
      end

      private

      # @api private
      def coerce(input)
        unless primitive?(input)
          return failure(
            input, CoercionError.new("#{input.inspect} must be an instance of #{primitive}")
          )
        end

        output = []
        failures = []

        input.each_with_index do |value, index|
          res_i = types_index[index]&.try(value)

          if res_i.nil?
            failures << CoercionError.new("#{value.inspect} not fits to the fixed-size tuple")
          elsif res_i.failure?
            failures << res_i.error
          else
            output << res_i.input
          end
        end

        if failures.empty?
          success(output)
        else
          failure(input, MultipleError.new(failures))
        end
      end
    end

    module BuilderMethods
      # Build a tuple type.
      #
      # @see Dry::Types::Tuple#build
      # @overload Tuple(*fixed_types, rest_type)
      #   @param [Array<Dry::Types::Type>] fixed_types
      #   @param [Array(Dry::Types::Type)] rest_type
      # @return [Dry::Types::Tuple]
      def Tuple(*types)
        Tuple.build(*types)
      end
    end

    # @api private
    class Printer
      MAPPING[Tuple] = :visit_tuple

      def visit_tuple(tuple)
        options = tuple.options.dup
        size = tuple.fixed_types.size
        size += 1 unless tuple.rest_type.nil?
        types = options.delete(:types_index)

        visit_options(options, tuple.meta) do |opts|
          header = "Tuple<"
          rest = visit(types.default) { |type| "*: #{type}" } if types.default

          if size.zero?
            yield "#{header}>#{opts}"
          else
            yield header.dup << (types.map { |pos, pos_type|
              visit(pos_type) { |type| "#{pos}: #{type}" }
              } << rest).compact.join(", ") << ">#{opts}"
          end
        end
      end
    end

    register "nominal.tuple", Types::Tuple.build([self['any']])

    type = self["nominal.tuple"].constrained(type: ::Array)

    register "tuple", type
    register "strict.tuple", type
    register "coercible.tuple", self["nominal.tuple"].constructor(Kernel.method(:Array))
    register "params.tuple", self["nominal.tuple"].constructor(Coercions::Params.method(:to_ary))
  end
end