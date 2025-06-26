# frozen_string_literal: true

module Dry::Types
  RSpec.describe Tuple do
    include_context 'shorthand types'

    describe '.extract_rest' do
      subject(:result) do
        _types = types
        _rest = Tuple.extract_rest(_types)
        { types: _types, rest: _rest }
      end

      context 'when none rest given' do
        let(:types) { [string_type, integer_type] }
        it { is_expected.to include(types: types, rest: undefined) }
      end

      context 'when single rest given' do
        let(:types) { [string_type, [integer_type]] }
        it { is_expected.to include(types: [string_type], rest: integer_type) }
      end

      context 'when list of rest given' do
        let(:types) { [integer_type, [string_type, symbol_type]] }
        it { is_expected.to include(types: [integer_type], rest: string_type | symbol_type) }
      end
    end

    describe "#valid?" do
      subject(:tuple) { tuple_of(string_type, integer_type) }

      it "detects invalid input of the completely wrong type" do
        expect(tuple.valid?(5)).to be(false)
      end

      it "detects invalid input of the wrong member type" do
        expect(tuple.valid?([5])).to be(false)
      end

      it "detects invalid input of the wrong order of fixed members" do
        expect(tuple.valid?([5, "five"])).to be(false)
      end

      it "recognizes valid input" do
        expect(tuple.valid?(["five", 5])).to be(true)
      end
    end

    describe "#===" do
      subject(:tuple) { tuple_of(string_type, integer_type) }

      it "returns boolean" do
        expect(tuple.===(%w[hello world])).to eql(false)
        expect(tuple.===(["hello", 1234])).to eql(true)
      end

      context "in case statement" do
        let(:value) do
          case ['hello', 1]
          when tuple then "accepted"
          else "invalid"
          end
        end

        it "returns correct value" do
          expect(value).to eql("accepted")
        end
      end
    end

    describe "#to_s" do
      subject(:type) { nominal_tuple_type }

      it "returns string representation of the type" do
        expect(type.to_s).to eql("#<Dry::Types[Tuple<*: Any>]>")
      end

      it "adds meta" do
        expect(type.meta(foo: :bar).to_s).to eql("#<Dry::Types[Tuple<*: Any> meta={foo: :bar}]>")
      end
    end

    context "member" do
      describe "#to_s" do
        subject(:type) { nominal_tuple_of(nominal_string_type, [nominal_integer_type]) }

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

          it { is_expected.to eq(tuple_of(integer_type) >> proc(&:to_a)) }

          it "makes type recursively lax" do
            expect(type.lax.fixed_types[0]).to eql(nominal_integer_type)
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
        let(:strings) { tuple_of([string_type]) }

        subject(:type) { tuple_of([strings]) }

        it "still discards constructor" do
          expect(type.constructor(&:to_a).rest_type.type).to eql(strings)
        end
      end
    end
  end
end