# Dry::Types::Tuple

The [Dry::Types](https://dry-rb.org/gems/dry-types) implementation of `Tuple` type as an array of fixed ordered items of specific type. It is useful for coercing positional arguments.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add dry-types-tuple

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install dry-types-tuple

## Usage

### Match & coerce fixed-size list of positional args

```ruby
args_tuple =
  Dry::Types['strict.tuple'].of \
    Dry::Types['params.symbol'],    # the type for the 1st item only
    Dry::Types['params.float']      # the type for the 2nd item only

args_tuple[['symbol', '0.001']]
# => [:symbol, 0.001]

args_tuple[['symbol', '0.001', '1']]
# => Dry::Types::MapError: "1" not fits to the fixed-size tuple
```

### Match & coerce variadic list of positional args

To match type of the rest of items just wrap a conclusive type into square brackets.

```ruby
args_tuple =
  Dry::Types['strict.tuple'].of \
    Dry::Types['params.symbol'],      # the type for the 1st item only
    Dry::Types['params.float'],       # the type for the 2nd item only
    [ Dry::Types['params.integer'] ]  # the type of the rest of items

args_tuple[['symbol', '0.001', '1', '2', '3']]
# => [:symbol, 0.001, 1, 2, 3]
```

Note, that array should have only one item, if you want match several types, make a Sum type.

```ruby
# BAD : will raise ArgumentError
Dry::Types['tuple'].of \
  Dry::Types['symbol'],
  [Dry::Types['float'], Dry::Types['integer']]

# GOOD
Dry::Types['tuple'].of \
  Dry::Types['symbol'],
  [Dry::Types['float'] | Dry::Types['integer']]
```

### Class interface mixins

The extra feature of the gem is tuple class interfaces mixins under the `Dry::Tuple` namespace. It isn't loaded by default,
so it's dependent on `require "dry/tuple"`.

#### Class interface for PORO-classes

The interfaces provide a way to use a tuple in constructors to match proper class by input.
The behaviour is similar to the one provided by `Dry::Struct::ClassInterface` and
allows to combine classes into sums but with positional input validation & coercion.

To do so, extend the class with `Dry::Tuple::ClassInterface` mixin and then assign an
explicit tuple type by calling `tuple(type_declation)` method.

With a couple of extended classes you will be able to compose a summing object, which
could be used to match incoming values by tuples. When input matches any of summed
tuples, it yields thru the type, performing coercions if need, but a top-level structure
of input keeps to be an Array. There are two abstract class methods — `coerce_tuple` and
`new_from_tuple`, — that could be redefined when, i.e., you need to splat an incoming
array into arguments due to avoid breaking the existing interface.

```ruby
class Example
  extend Dry::Tuple::ClassInterface
  tuple Types.Tuple(Types.Value(:example) << Types::Coercible::Symbol, Types::String)

  def initialize(left, right)
    @left, @right = left, right
  end

  # @note Used by {StructClassInterface} under the hood.
  # @param input [Array] after sub types coercion
  # @return [Any] args acceptable by {#initializer}.
  # def self.coerce_tuple(input)
  #   input
  # end

  # @param input [Any] after {.coerce_tuple}
  # @return [self] instantiated object with the given arguments
  def self.new_from_tuple(input)
    new(*input)
  end
end

class OtherExample < Example
  tuple Types.Tuple(Types.Value(:other_example) << Types::Coercible::Symbol, [Types::Any])

  def initialize(left, right, *rest)
    super(left, right)
    @rest = rest
  end
end

ExampleSum = Example | OtherExample
ExampleSum[['example', 'foo']]
# => #<Example @left = :example, @right = 'foo'>

ExampleSum[['other_example', 1, '2', {}]].class
# => #<OtherExample @left = :other_example, @right = 1, @rest = ['2', {}]>
```

#### Class interface for Dry::Struct classes.

And, the initial target of this gem, — let `Dry::Struct` classes to take both the key-value and
the tuple inputs. Extend `Dry::Struct` classes with the `Dry::Tuple::StructClassInterface`,
ensure keys order with helper method `auto_tuple *keys` (it will auto-declare the tuple from the struct's schema)…
Profit!

```ruby
class SomeStruct < Dry::Struct
  attribute :some, Types::Integer
  attribute :with, Types::Hash
  extend ::Dry::Tuple::StructClassInterface
  auto_tuple :some, :with
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/estum/dry-types-tuple. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/estum/dry-types-tuple/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Dry::Types::Tuple project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/estum/dry-types-tuple/blob/main/CODE_OF_CONDUCT.md).
