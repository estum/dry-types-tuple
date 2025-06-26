require 'dry/tuple/struct'

RSpec.shared_context 'dry struct interfaces', interfaces: :dry_struct do
  include_context 'shorthand types'

  let(:base_struct) do
    Dry::Tuple::Struct
  end

  let(:node_constructor) do
    -> (input, type) { type.try(input).success? ? nodes_sum.(input) : input }
  end

  let(:nodelike) do
    Dry::Types::Nominal.new(base_struct) << node_constructor
  end

  let(:unary_node_class) do
    Class.new(base_struct).tap do
      _1.attribute :name, coercible_symbol_type.constrained(is: :unary)
      _1.attribute :node, nodelike

      _1.auto_tuple :name, :node
    end
  end

  let(:binary_node_class) do
    Class.new(base_struct).tap do
      _1.attribute :name, coercible_symbol_type.constrained(is: :binary)
      _1.attribute :left, nodelike
      _1.attribute :right, nodelike

      _1.auto_tuple :name, :left, :right
    end
  end

  let(:expr_node_class) do
    Class.new(base_struct).tap do
      _1.attribute :name, coercible_symbol_type
      _1.attribute :expr, string_type

      _1.auto_tuple :name, :expr
    end
  end

  let(:nodes_sum) do
    unary_node_class | binary_node_class | expr_node_class
  end

  let(:unary_node_stubbed) do
    stub_const('ExampleUnaryNode', unary_node_class)
  end

  let(:binary_node_stubbed) do
    stub_const('ExampleBinaryNode', binary_node_class)
  end

  let(:expr_node_stubbed) do
    stub_const('ExampleExprNode', expr_node_class)
  end

  let(:nodes_sum_stubbed) do
    stub_const('ExampleNodesSum', unary_node_stubbed | binary_node_stubbed | expr_node_stubbed)
  end
end