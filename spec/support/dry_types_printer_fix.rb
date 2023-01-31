unless Dry::Types::Printer.method_defined?(:visit_sum_constructors)
  class Dry::Types::Printer
    alias_method :visit_sum_constructors, :visit_composition
  end
end