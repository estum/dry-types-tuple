RSpec.shared_context 'poro interfaces', interfaces: :poro do
  extend LetStub

  include_context 'shorthand types'

  let_stub_class :poro, (proc do
    attr_reader :arg1, :arg2
    def initialize((arg1, arg2)); @arg1, @arg2 = arg1, arg2; end
  end)

  let_stub_class(:poro_str_int, parent: :poro_class) do |sub|
    sub.tuple tuple_of(string_type, coercible_integer_type)
  end

  let_stub_class(:poro_sym_hash, parent: :poro_class) do |sub|
    sub.tuple tuple_of(symbol_type, hash_type)
  end

  let_stub_const(:poro, memo_suffix: :sum) do
    poro_str_int_class | poro_sym_hash_class
  end
end