# frozen_string_literal: true

require 'dry/tuple'
require 'dry/initializer'

module Dry::Tuple
  RSpec.describe StructClassInterface, shorthand: :types do
    subject(:mixin) { described_class }

    before { klass.extend(mixin) }

    context 'used within a sample PORO-class', interfaces: :dry_struct do
      let(:klass) { base_struct_class }

      it { is_expected.to eq(klass.singleton_class.ancestors[0]) }

      it 'has accessable tuple' do
        expect(unary_node_class).to have_attributes(tuple: be_kind_of(Dry::Types::Type))
        expect(binary_node_class).to have_attributes(tuple: be_kind_of(Dry::Types::Type))
        expect(expr_node_class).to have_attributes(tuple: be_kind_of(Dry::Types::Type))
      end

      context 'on sum of subclasses inherited from extended class' do
        subject(:sum) { nodes_sum }

        it '#<Dry::Types[Struct::Sum<Sum<ExampleUnaryNode | ExampleBinaryNode | ExampleExprNode>>]>' do |ex|
          expect { print sum }.to output(ex.description).to_stdout
        end
        describe 'sum[]' do
          subject(:output) { |ex| sum[ex.metadata[:input]] }

          {
            [:other, 'FOO'] => :expr_node_class,
            [:unary,
              [:other, 'BAR']] => :unary_node_class,
            [:binary,
              [:other, 'FOO'],
              [:unary, [:other, 'BAR']]] => :binary_node_class,
          }.each { |input, klass|
            klass_name = inflector.classify("example_#{klass.to_s.delete_suffix('_class')}")
            it "correctly matches #{klass_name} class on input #{input}", input: input do |ex|
              is_expected.to be_instance_of(self.then(&klass))
            end
          }

          it 'correctly coerces attributes of nodes' do
            expect(sum[[:other, 'FOO']]).
              to have_attributes(name: :other, expr: 'FOO')

            expect(sum[[:unary, [:other, 'BAR']]]).
              to have_attributes(
                name: :unary,
                node: be_instance_of(expr_node_class) & have_attributes(name: :other, expr: 'BAR')
              )

            expect(sum[[:binary, [:other, 'FOO'], [:unary, [:other, 'BAR']]]]).
              to have_attributes(
                name: :binary,
                left: be_instance_of(expr_node_class).
                        and(have_attributes(name: :other, expr: 'FOO')),
                right: be_instance_of(unary_node_class).
                         and(have_attributes(
                           name: :unary,
                           node: be_instance_of(expr_node_class).
                                 and(have_attributes(name: :other, expr: 'BAR'))
                       ))
              )
          end
        end
      end
    end
  end
end