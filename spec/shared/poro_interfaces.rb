RSpec.shared_context 'poro interfaces', interfaces: :poro do
  include_context 'shorthand types'

  let(:poro_class) do
    Class.new do
      extend Dry::Tuple::ClassInterface
      attr_reader :arg1, :arg2
      def initialize((arg1, arg2))
        @arg1, @arg2 = arg1, arg2
      end
    end
  end

  let(:poro_str_int_class) do
    Class.new(poro_class).tap { _1.tuple tuple(string, coercible_integer) }
  end

  let(:poro_sym_hash_class) do
    Class.new(poro_class).tap { _1.tuple tuple(symbol, strict_hash) }
  end

  let(:poro_sum) do
    poro_str_int_class | poro_sym_hash_class
  end

  let(:poro_stubbed) do
    stub_const('ExamplePoro', poro_class)
  end

  let(:poro_str_int_stubbed) do
    stub_const('ExamplePoroStrInt', poro_str_int_class)
  end

  let(:poro_sym_hash_stubbed) do
    stub_const('ExamplePoroSymHash', poro_sym_hash_class)
  end

  let(:poro_sum_stubbed) do
    stub_const('ExamplePoroSum', poro_str_int_stubbed | poro_sym_hash_stubbed)
  end
end