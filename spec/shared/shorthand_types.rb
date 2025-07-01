RSpec.shared_context 'shorthand types', shorthand: :types do
  def tuple(*args)
    Dry::Types['tuple'].of(*args)
  end

  def nominal_tuple(*args)
    type = Dry::Types['nominal.tuple']
    args.size > 0 ? type.of(*args) : type
  end

  def strict(klass)
    Dry::Types::Nominal.new(klass).constrained(type: klass)
  end

  let(:any) { Dry::Types['any'] }
  let(:date) { Dry::Types['date'] }
  let(:integer) { Dry::Types['integer'] }
  let(:float) { Dry::Types['float'] }
  let(:strict_hash) { Dry::Types['hash'] }
  let(:string) { Dry::Types['string'] }
  let(:symbol) { Dry::Types['symbol'] }

  let(:nominal_integer) { Dry::Types['nominal.integer'] }
  let(:nominal_string) { Dry::Types['nominal.string'] }

  let(:coercible_integer) { Dry::Types['coercible.integer'] }
  let(:coercible_symbol) { Dry::Types['coercible.symbol'] }
end