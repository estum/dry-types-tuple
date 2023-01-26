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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/estum/dry-types-tuple. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/estum/dry-types-tuple/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Dry::Types::Tuple project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/estum/dry-types-tuple/blob/main/CODE_OF_CONDUCT.md).
