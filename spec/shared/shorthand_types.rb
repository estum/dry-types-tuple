RSpec.shared_context 'shorthand types', shorthand: :types do
  def tuple_of(*args)
    Dry::Types['tuple'].of(*args)
  end

  def nominal_tuple_of(*args)
    Dry::Types['nominal.tuple'].of(*args)
  end

  def strict(klass)
    Dry::Types::Nominal.new(klass).constrained(type: klass)
  end

  let(:any_type)     { Dry::Types['any'] }
  let(:date_type)    { Dry::Types['date'] }
  let(:integer_type) { Dry::Types['integer'] }
  let(:hash_type)    { Dry::Types['hash'] }
  let(:string_type)  { Dry::Types['string'] }
  let(:symbol_type)  { Dry::Types['symbol'] }

  let(:nominal_tuple_type) { Dry::Types['nominal.tuple'] }
  let(:nominal_integer_type) { Dry::Types['nominal.integer'] }
  let(:nominal_string_type) { Dry::Types['nominal.string'] }

  let(:coercible_integer_type) { Dry::Types['coercible.integer'] }
  let(:coercible_symbol_type)  { Dry::Types['coercible.symbol'] }
end