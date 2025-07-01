module Dry
  RSpec.describe Types, shorthand: :types do
    describe 'Dry::Types[...]' do
      subject(:resolved) { |ex| described_class[ex.description] }

      specify 'string|integer' do
        is_expected.to eq (string | integer)
      end

      specify 'string|symbol|integer' do
        is_expected.to eq (string | symbol | integer)
      end

      specify 'tuple<string,integer>' do
        is_expected.to eq tuple(string, integer)
      end

      specify 'tuple<string,integer|float>' do
        is_expected.to eq tuple(string, integer | float)
      end

      specify 'tuple<string,integer,[hash]>' do
        is_expected.to eq tuple(string, integer, [strict_hash])
      end

      specify 'tuple<string,tuple<integer,symbol>>' do
        is_expected.to eq tuple(string, tuple(integer, symbol))
      end

      specify 'tuple<string,tuple<integer|float,symbol>>' do
        is_expected.to eq tuple(string, tuple(integer | float, symbol))
      end

      specify 'tuple<string,tuple<integer,symbol>,[hash]>' do
        is_expected.to eq tuple(string, tuple(integer, symbol), [strict_hash])
      end

      specify 'tuple<integer,float,[string|symbol]>' do
        is_expected.to eq tuple(integer, float, [string | symbol])
      end

      specify 'tuple<string,integer|float,[string|symbol]>' do
        is_expected.to eq tuple(string, integer | float, [string | symbol])
      end

      specify 'tuple<integer,tuple<integer,float>,[string|symbol]>' do
        is_expected.to eq tuple(integer, tuple(integer, float), [string | symbol])
      end

      specify 'tuple<integer,[string|symbol]>|tuple<string,[hash]>' do
        is_expected.to eq (tuple(integer, [string | symbol]) | tuple(string, [strict_hash]))
      end
    end
  end
end
