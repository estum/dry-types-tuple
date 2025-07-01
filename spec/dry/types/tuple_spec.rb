# frozen_string_literal: true

module Dry::Types
  RSpec.describe Tuple do
    include_context 'shorthand types'

    describe '.extract_rest' do
      subject(:result) do
        types = types()
        { types:, rest: Tuple.extract_rest(types) }
      end

      context 'when none rest given' do
        let(:types) { [string, integer] }
        it { is_expected.to include(types:, rest: undefined) }
      end

      context 'when single rest given' do
        let(:types) { [string, [integer]] }
        it { is_expected.to include(types: [string], rest: integer) }
      end

      context 'when list of rest given' do
        let(:types) { [integer, [string, symbol]] }
        it { is_expected.to include(types: [integer], rest: string | symbol) }
      end

      context 'when single rest of sum type given' do
        let(:types) { [integer, [string | symbol]] }
        it { is_expected.to include(types: [integer], rest: string | symbol) }
      end
    end

    describe '#types_index' do
      subject(:tuple_type) { tuple(string, integer, [string | symbol]).types_index }

      it { is_expected.to include(0 => string, 1 => integer) }
      it { is_expected.to have_attributes(default: string | symbol) }
    end

    describe "#valid?" do
      subject(:tuple_type) { tuple(string, integer) }

      it "detects invalid input of the completely wrong type" do
        expect(tuple_type.valid?(5)).to be(false)
      end

      it "detects invalid input of the wrong member type" do
        expect(tuple_type.valid?([5])).to be(false)
      end

      it "detects invalid input of the wrong order of fixed members" do
        expect(tuple_type.valid?([5, "five"])).to be(false)
      end

      it "recognizes valid input" do
        expect(tuple_type.valid?(["five", 5])).to be(true)
      end
    end

    describe "#===" do
      subject(:tuple_type) { tuple(string, integer) }

      it "returns boolean" do
        expect(tuple_type === %w[hello world]).to eql(false)
        expect(tuple_type === ["hello", 1234]).to eql(true)
      end

      context "in case statement" do
        let(:value) do
          case ['hello', 1]
          when tuple_type then "accepted"
          else "invalid"
          end
        end

        it "returns correct value" do
          expect(value).to eql("accepted")
        end
      end
    end

    describe "#to_s" do
      subject(:type) { nominal_tuple }

      it "returns string representation of the type" do
        expect(type.to_s).to eql("#<Dry::Types[Tuple<*: Any>]>")
      end

      it "adds meta" do
        expect(type.meta(foo: :bar).to_s).to eql("#<Dry::Types[Tuple<*: Any> meta={foo: :bar}]>")
      end
    end

    context "member" do
      describe "#to_s" do
        subject(:type) { nominal_tuple(nominal_string, [nominal_integer]) }

        it "returns string representation of the type" do
          expect(type.to_s).to eql("#<Dry::Types[Tuple<0: Nominal<String>, *: Nominal<Integer>>]>")
        end

        it "shows meta" do
          expect(type.meta(foo: :bar).to_s).to eql("#<Dry::Types[Tuple<0: Nominal<String>, *: Nominal<Integer>> meta={foo: :bar}]>")
        end
      end

      describe "#constructor" do
        subject(:type) { Dry::Types["params.tuple<params.integer>"] }

        example "getting member from a constructor type" do
          expect(type.fixed_types[0].("1")).to be(1)
        end

        describe "#lax" do
          subject(:type) { Dry::Types["tuple<integer>"].constructor(&:to_a) }

          it { is_expected.to eq(tuple(integer) >> proc(&:to_a)) }

          it "makes type recursively lax" do
            expect(type.lax.fixed_types[0]).to eql(nominal_integer)
          end
        end

        describe "#constrained" do
          it "applies constraints on top of constructor" do
            expect(type.constrained(size: 1).(["1"])).to eql([1])
            expect(type.constrained(size: 1).([]) { :fallback }).to be(:fallback)
          end
        end
      end

      context "nested tuple" do
        let(:strings) { tuple([string]) }

        subject(:type) { tuple([strings]) }

        it "still discards constructor" do
          expect(type.constructor(&:to_a).type.rest_type).to eql(strings)
        end
      end
    end
  end
end