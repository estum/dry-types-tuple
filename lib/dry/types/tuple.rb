# frozen_string_literal: true

require "dry/tuple"

module Dry
  module Types
    # @example
    #   Types::ServiceArgs = Types.Tuple(
    #     Types::Params::Symbol,                                # --- positional types
    #     [Types::Params::Integer | Types::Coercible::String]   # --- [type for the rest items]
    #   )
    #   Types::ServiceArgs[['thumb', '300', '300', 'sample']]
    #   # => [:thumb, 300, 300, "sample"]
    class Tuple < Nominal
      # VERSION ||= Dry::Tuple::VERSION

      # Build a tuple type.
      #
      # @overload self.build(*fixed_types, rest_type)
      #   @param [Array<Dry::Types::Type>] fixed_types
      #   @param [Array(Dry::Types::Type)] rest_type
      # @see self.build_index
      # @return [Dry::Types::Tuple]
      def self.build(*types, **opts)
        coerce(types, **opts)
      end

      # Prepares types index for the Tuple
      # @see self.extract_rest
      # @param types [Array<Type>]
      # @return [Hash { Integer => Type }]
      def self.build_index(types)
        types_index = {}

        Undefined.map(extract_rest(types)) do |rest_type|
          types_index.default = rest_type
        end

        types.each_with_index do |type, index|
          types_index[index] = type
        end

        types_index
      end

      # Extracts the rest type or types.
      # More than one types in list will be composed to {Sum}.
      # @note
      #   Destructive on input arrays.
      # @param types [Array<Type, Sum>]
      # @return [Undefined, Type, Sum]
      def self.extract_rest(types)
        case types
        in *head, ::Array => rest if rest.size > 0
          types.replace(head)
          rest.reduce(:|)
        else
          Undefined
        end
      end

      # @api private
      def self.coerce(types, **opts)
        types_index = build_index(types)
        new(::Array, **opts, types_index:)
      end

      singleton_class.alias_method :build_unsplat, :coerce

      # @param primitive [Class]
      # @return [self]
      def initialize(primitive, types_index: EMPTY_HASH, meta: EMPTY_HASH, **opts)
        super(primitive, **opts, types_index:, meta:)
      end

      # @api public

      # @see Tuple.build
      # @return [Dry::Types::Tuple]
      def of(*types)
        with(types_index: self.class.build_index(types))
      end

      # @return [Hash]
      def types_index = options[:types_index]

      # @return [Array<Type>]
      def fixed_types = types_index.values

      # @return [Type]
      def rest_type = types_index.default

      # @return [String]
      def name = 'Tuple'

      # @param [Array] tuple
      # @return [Result]
      def try(tuple)
        result = coerce(tuple)
        return result if result.success? || !block_given?
        yield(result)
      end

      # Build a lax type
      # @return [Lax]
      def lax
        types_index = types_index().transform_values(&:lax)
        types_index.default = rest_type.lax if rest_type
        Lax.new(Tuple.new(primitive, **options, types_index:, meta:))
      end

      # @param meta [Boolean] Whether to dump the meta to the AST
      # @return [Array] An AST representation
      def to_ast(meta: true)
        structure = [*fixed_types.map { _1.to_ast(meta:) }]
        structure << [rest_type.to_ast(meta:)] unless rest_type.nil?
        structure << meta ? meta() : EMPTY_HASH
        [:tuple, structure]
      end

      # @return [Boolean]
      def constrained?
        rest_type&.constrained? || types_index.each_value.any?(&:constrained?)
      end

      # @param tuple [Array]
      # @return [Array]
      # @api private
      def call_unsafe(tuple)
        try(tuple) { raise MapError, _1.error.message }.input
      end

      # @param tuple [Array]
      # @return [Array]
      # @api private
      def call_safe(tuple)
        try(tuple) { return yield }.input
      end

      private

      # @api private
      def coerce(input)
        unless primitive?(input)
          return failure(input, CoercionError.new("#{input.inspect} must be an instance of #{primitive}"))
        end

        output = []
        failures = []

        input.each_with_index do |value, index|
          item = types_index[index]&.try(value)

          if item.nil?
            failures << CoercionError.new("#{value.inspect} not fits to the fixed-size tuple")
            break
          elsif item.failure?
            failures << item.error
            break
          else
            output << item.input
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
      # @see Tuple.build
      # @overload Tuple(*fixed_types, rest_type)
      #   @param [Array<Type>] fixed_types
      #   @param [Array(Type)] rest_type
      # @return [Tuple]
      def Tuple(...)
        Tuple.build(...)
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
          rest = visit(types.default) { "*: #{_1}" } if types.default

          if size.zero?
            yield "#{header}>#{opts}"
          else
            yield header.dup << (
              types.flat_map do |pos, pos_types|
                Kernel.Array(pos_types).map do |pos_type|
                  visit(pos_type) { "#{pos}: #{_1}" }
                end
              end << rest
            ).compact.join(", ") << ">#{opts}"
          end
        end
      end
    end

    nominal_tuple = Tuple.build([self['any']])

    register "nominal.tuple", nominal_tuple

    strict_tuple = nominal_tuple.constrained(type: ::Array)

    register "tuple", strict_tuple
    register "strict.tuple", strict_tuple
    register "coercible.tuple", nominal_tuple.constructor(Kernel.method(:Array))
    register "params.tuple", nominal_tuple.constructor(Coercions::Params.method(:to_ary))

    TUPLE_PREFIX_REGEX = /(?:(?:coercible|nominal|params|strict)\.)?tuple(?=\<)/
    TUPLE_MEMBERS_REGEX = /(?<=tuple<).+(?=>)/
    TUPLE_MEMBERS_SCAN_REGEX = /(tuple\<(?:\g<1>\,)*\g<1>\>|\[(\g<1>)\](?=$)|[^,]+)(?=,|$)/
    SUM_MATCH_REGEX = /((?:(?:\A|\|)(?:[^\|]+))*)\|([^\|]+)\z/

    # @api private
    module ReferenceHook
      def [](name)
        case name
        when TUPLE_PREFIX_REGEX
          type_map.fetch_or_store(name) do
            key = Regexp.last_match[0]
            types =
              name[TUPLE_MEMBERS_REGEX].
                scan(TUPLE_MEMBERS_SCAN_REGEX).
                map { |(type, rest)| rest.nil? ? self[type] : [self[rest]] }
            super(key).of(*types)
          end
        when SUM_MATCH_REGEX
          type_map.fetch_or_store(name) do
            left, right = Regexp.last_match.captures
            self[left] | super(right)
          end
        else
          super(name)
        end
      end
    end

    singleton_class.prepend ReferenceHook
  end
end