RSpec.shared_context 'dry initializer interfaces', interfaces: :dry_initializer do
  extend LetStub

  include_context 'shorthand types'

  let_stub_class(:dry_initializer, proc {
    extend Dry::Initializer
    def self.new_from_tuple(input); new(*input); end
  }) do |k|
    k.param :common, coercible_integer_type
  end

  let_stub_class(:di_int_str_str, parent: :dry_initializer_class) do |sub|
    sub.param :arg2, type: string_type
    sub.param :arg3, type: string_type
    sub.tuple tuple_of(coercible_integer_type, [string_type])
  end

  let_stub_class(:di_int_date, parent: :dry_initializer_class) do |sub|
    sub.param :date, date_type
    sub.tuple tuple_of(coercible_integer_type, date_type)
  end

  let_stub_const(:di, memo_suffix: :sum) do
    di_int_str_str_class | di_int_date_class
  end
end