RSpec.shared_context 'dry initializer interfaces', interfaces: :dry_initializer do
  include_context 'shorthand types'

  let(:dry_initializer_class) do
    Class.new do
      extend Dry::Tuple::ClassInterface
      extend Dry::Initializer[undefined: false]

      def self.new_from_tuple(input)
        new(*input)
      end
    end.tap do
      _1.param :common, type: coercible_integer_type
    end
  end

  let(:di_int_str_str_class) do
    Class.new(dry_initializer_class).tap do
      _1.param :arg2, type: string_type
      _1.param :arg3, type: string_type
      _1.tuple tuple_of(coercible_integer_type, [string_type])
    end
  end

  let(:di_int_date_class) do
    Class.new(dry_initializer_class).tap do
      _1.param :date, type: date_type
      _1.tuple tuple_of(coercible_integer_type, date_type)
    end
  end

  let(:di_sum) do
    di_int_str_str_class | di_int_date_class
  end

  let(:di_stubbed) do
    stub_const('ExampleDi', dry_initializer_class)
  end

  let(:di_int_str_str_stubbed) do
    stub_const('ExampleDiIntStrStr', di_int_str_str_class)
  end

  let(:di_int_date_stubbed) do
    stub_const('ExampleDiIntDate', di_int_date_class)
  end

  let(:di_sum_stubbed) do
    stub_const('ExampleDiSum', di_int_str_str_stubbed | di_int_date_stubbed)
  end

end