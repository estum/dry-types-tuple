# frozen_string_literal: true

require 'dry/initializer'

module Dry::Tuple
  RSpec.describe Struct, shorthand: :types do
    subject(:superklass) { described_class }

    context 'on singleton class' do
      subject(:singleton_klass) { superklass.singleton_class }
      it { is_expected.to be < Struct::ClassInterface }
    end

    context 'used within a sample PORO-class', interfaces: :dry_struct do
      it 'has accessable tuple' do
        expect(unary_node_stubbed).to have_attributes(tuple: be_kind_of(Dry::Types::Type))
        expect(binary_node_stubbed).to have_attributes(tuple: be_kind_of(Dry::Types::Type))
        expect(expr_node_stubbed).to have_attributes(tuple: be_kind_of(Dry::Types::Type))
      end

      context 'on sum of subclasses inherited from extended class' do
        subject(:sum) { nodes_sum_stubbed }

        it '#<Dry::Types[Struct::Sum<Sum<ExampleUnaryNode | ExampleBinaryNode | ExampleExprNode>>]>' do |ex|
          expect { print sum }.to output(ex.description).to_stdout
        end

        describe '#try' do
          subject(:result) { |ex| sum.try(ex.metadata[:input]) }

          it 'succeeds on tuple input', input: [:other, 'FOO'] do
            is_expected.to be_success
          end

          it 'succeeds on hash input', input: { name: :other, expr: 'FOO' } do
            is_expected.to be_success
          end
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
          }.each do |input, klass|
            klass_name = inflector.classify("example_#{klass.to_s.delete_suffix('_class')}")
            it "correctly matches #{klass_name} class on input #{input}", input: input do |ex|
              is_expected.to be_instance_of(self.then(&klass))
            end
          end

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