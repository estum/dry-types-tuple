require 'dry/struct'

RSpec.shared_context 'dry struct interfaces', interfaces: :dry_struct do
  extend LetStub
  include_context 'shorthand types'

  def self.extending_closure
    proc { extend ::Dry::Tuple::StructClassInterface }
  end

  def self.parent_dry_struct
    proc { Dry::Struct }
  end

  let(:nodelike) do
    Dry::Types::Nominal.new(base_struct_class).
      constructor do |input, type|
        if type.try(input).success?
          nodes_sum.(input)
        else
          input
        end
      end
  end

  let_stub_class(:base_struct, extending_closure, parent: parent_dry_struct)

  let_stub_class(:unary_node, parent: :base_struct_class) do |sub|
    sub.attribute :name, coercible_symbol_type.constrained(is: :unary)
    sub.attribute :node, nodelike
    sub.auto_tuple :name, :node
  end

  let_stub_class(:binary_node, parent: :base_struct_class) do |sub|
    sub.attribute :name, coercible_symbol_type.constrained(is: :binary)
    sub.attribute :left, nodelike
    sub.attribute :right, nodelike
    sub.auto_tuple :name, :left, :right
  end

  let_stub_class(:expr_node, parent: :base_struct_class) do |sub|
    sub.attribute :name, coercible_symbol_type
    sub.attribute :expr, string_type
    sub.auto_tuple :name, :expr
  end

  let_stub_const(:nodes, memo_suffix: :sum) do
    unary_node_class | binary_node_class | expr_node_class
  end
end