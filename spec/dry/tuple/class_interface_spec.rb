# frozen_string_literal: true

require 'dry/tuple'
require 'dry/initializer'

module Dry::Tuple
  RSpec.describe ClassInterface, shorthand: :types do
    subject(:mixin) { described_class }

    before { klass.extend(mixin) }

    context 'used within a sample PORO-class', interfaces: :poro do
      let(:klass) { poro_class }

      it { is_expected.to eq(klass.singleton_class.ancestors[0]) }

      context 'on sum of subclasses inherited from extended class' do
        subject(:sum) { poro_sum }

        it '#<Dry::Types[Sum<ExamplePoroStrInt | ExamplePoroSymHash>]>' do |ex|
          expect { print sum }.to output(ex.description).to_stdout
        end

        describe 'sum[]' do
          subject(:output) { |ex| sum[ex.metadata[:input]] }

          {
            ['a',  1 ] => :poro_str_int_class,
            ['a', '1'] => :poro_str_int_class,
            ['a', 1.0] => :poro_str_int_class,
            [:a , { }] => :poro_sym_hash_class
          }.each { |input, klass|
            klass_name = inflector.classify("example_#{klass.to_s.delete_suffix('_class')}")
            it "correctly matches #{klass_name} class on input #{input}", input: input do |ex|
              is_expected.to be_instance_of(self.then(&klass))
            end
          }
        end
      end
    end

    context 'used within a sample class extended with Dry::Initializer', interfaces: :dry_initializer do
      let(:klass) { dry_initializer_class }

      it { is_expected.to eq(klass.singleton_class.ancestors[0]) }

      context 'on sum of subclasses inherited from extended class' do
        subject(:sum) { di_sum }

        it '#<Dry::Types[Sum<ExampleDiIntStrStr | ExampleDiIntDate>]>' do |ex|
          expect { print sum }.to output(ex.description).to_stdout
        end

        describe 'sum[]' do
          subject(:output) { |ex| sum[ex.metadata[:input]] }

          {
            [ 1 , 'a', 'b'  ] => :di_int_str_str_class,
            ['1', 'a', 'b'  ] => :di_int_str_str_class,
            ['1', Date.today] => :di_int_date_class
          }.each { |input, klass|
            klass_name = inflector.classify("example_#{klass.to_s.delete_suffix('_class')}")
            it "correctly matches #{klass_name} class on input #{input}", input: input do |ex|
              is_expected.to be_instance_of(self.then(&klass))
            end
          }
        end
      end
    end
  end
end