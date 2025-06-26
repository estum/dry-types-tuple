# frozen_string_literal: true

require 'dry/tuple'
require 'dry/initializer'

module Dry::Tuple
  RSpec.describe ClassInterface, shorthand: :types do
    subject(:mixin) { described_class }

    context 'used within a sample PORO-class', interfaces: :poro do
      subject(:klass) { poro_stubbed }

      context 'on singleton class' do
        subject(:singleton_klass) { klass.singleton_class }
        it { is_expected.to be < mixin }
      end

      context 'on inherited class' do
        subject(:subklass) { poro_str_int_stubbed }
        it { is_expected.to be < klass }

        it 'has tuple' do
          expect(subklass.tuple).not_to be_nil
        end
      end

      context 'on sum of subclasses inherited from extended class' do
        subject(:sum) { poro_sum_stubbed }

        it '#<Dry::Types[Sum<ExamplePoroStrInt | ExamplePoroSymHash>]>' do |ex|
          expect { print sum }.to output(ex.description).to_stdout
        end

        describe 'sum[]' do
          subject(:output) { |ex| sum[ex.metadata[:input]] }

          {
            ['a',  1 ] => ['ExamplePoroStrInt', proc { poro_str_int_stubbed }],
            ['a', '1'] => ['ExamplePoroStrInt', proc { poro_str_int_stubbed }],
            ['a', 1.0] => ['ExamplePoroStrInt', proc { poro_str_int_stubbed }],
            [:a , {}] => ['ExamplePoroSymHash', proc { poro_sym_hash_stubbed }]
          }.each do |input, (klass_name, klass)|
            it "correctly matches #{klass_name} class on input #{input}", input: input do |ex|
              is_expected.to be_instance_of(ex.instance_exec(&klass))
            end
          end
        end
      end
    end

    context 'used within a sample class extended with Dry::Initializer', interfaces: :dry_initializer do
      subject(:klass) { di_stubbed }

      context 'on singleton class' do
        subject(:singleton_klass) { klass.singleton_class }
        it { is_expected.to be < mixin }
      end

      context 'on sum of subclasses inherited from extended class' do
        subject(:sum) { di_sum_stubbed }

        it '#<Dry::Types[Sum<ExampleDiIntStrStr | ExampleDiIntDate>]>' do |ex|
          expect { print sum }.to output(ex.description).to_stdout
        end

        describe 'sum[]' do
          subject(:output) { |ex| sum[ex.metadata[:input]] }

          {
            [ 1 , 'a', 'b'] => ['ExampleDiIntStrStr', proc { di_int_str_str_stubbed }],
            ['1', 'a', 'b'] => ['ExampleDiIntStrStr', proc { di_int_str_str_stubbed }],
            ['1', Date.today] => ['ExampleDiIntDate', proc { di_int_date_stubbed }]
          }.each do |input, (klass_name, klass)|
            it "correctly matches #{klass_name} class on input #{input}", input: input do |ex|
              is_expected.to be_instance_of(ex.instance_exec(&klass))
            end
          end
        end
      end
    end
  end
end