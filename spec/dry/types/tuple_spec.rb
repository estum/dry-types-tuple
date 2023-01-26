# frozen_string_literal: true

module Dry::Types
  RSpec.describe Tuple do
    describe "#valid?" do
      subject(:tuple) { Dry::Types["tuple"].of(Dry::Types["string"], Dry::Types['integer']) }

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
      subject(:tuple) { Dry::Types["strict.tuple"].of(Dry::Types["strict.string"], Dry::Types['integer']) }

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

    context "member" do
      describe "#to_s" do
        subject(:type) { Dry::Types["nominal.tuple"].of(Dry::Types["nominal.string"], [Dry::Types['nominal.integer']]) }

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

          it "makes type recursively lax" do
            expect(type.lax.fixed_types[0]).to eql(Dry::Types["nominal.integer"])
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
        let(:strings) do
          Dry::Types["tuple"].of([Dry::Types["string"]])
        end

        subject(:type) do
          Dry::Types["tuple"].of([strings])
        end

        it "still discards constructor" do
          expect(type.constructor(&:to_a).rest_type.type).to eql(strings)
        end
      end
    end

    describe "#to_s" do
      subject(:type) { Dry::Types["nominal.tuple"] }

      it "returns string representation of the type" do
        expect(type.to_s).to eql("#<Dry::Types[Tuple<*: Any>]>")
      end

      it "adds meta" do
        expect(type.meta(foo: :bar).to_s).to eql("#<Dry::Types[Tuple<*: Any> meta={foo: :bar}]>")
      end
    end
  end
end