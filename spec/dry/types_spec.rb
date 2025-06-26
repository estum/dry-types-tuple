module Dry
  RSpec.describe Types do
    describe 'Dry::Types[...]' do
      subject(:resolved) { |ex| described_class[ex.description] }

      specify 'string|integer' do
        is_expected.to eq Types['string'] | Types['integer']
      end

      specify 'string|symbol|integer' do
        is_expected.to eq Types['string'] | Types['symbol'] | Types['integer']
      end

      specify 'tuple<string,integer>' do
        is_expected.to eq \
          Types['tuple'].of(
            Types['string'],
            Types['integer']
          )
      end

      specify 'tuple<string,integer,[hash]>' do
        is_expected.to eq \
          Types['tuple'].of(
            Types['string'],
            Types['integer'],
            [Types['hash']]
          )
      end

      specify 'tuple<string,tuple<integer,symbol>>' do
        is_expected.to eq \
          Types['tuple'].of(
            Types['string'],
            Types['tuple'].of(
              Types['integer'],
              Types['symbol']
            )
          )
      end

      specify 'tuple<string,tuple<integer,symbol>,[hash]>' do
        is_expected.to eq \
          Types['tuple'].of(
            Types['string'],
            Types['tuple'].of(
              Types['integer'],
              Types['symbol']
            ),
            [Types['hash']]
          )
      end

      specify 'tuple<integer,float,[string|symbol]>' do
        is_expected.to eq \
          Types['tuple'].of(
            Types['integer'],
            Types['float'],
            [Types['string'] | Types['symbol']]
          )
      end

      specify 'tuple<integer,tuple<integer,float>,[string|symbol]>' do
        is_expected.to eq \
          Types['tuple'].of(
            Types['integer'],
            Types['tuple'].of(
              Types['integer'],
              Types['float']
            ),
            [Types['string'] | Types['symbol']]
          )
      end
    end
  end
end
