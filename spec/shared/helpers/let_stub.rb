# frozen_string_literal: true

module LetStub
  # @param name [String, Symbol]
  # @param fn [Proc] that will be executed in the Class context
  # @param parent [Proc] that returns parent class to inherit (called in the Example context)
  # @param block [Proc] that will be executed in the example's context yielding the created class
  def let_stub_class(name, fn = nil, parent: proc { Object }, &block)
    let_stub_const name, memo_suffix: :class do |ex|
      object = Class.new(ex.instance_exec(self, &parent), &(fn || proc {}))
      ex.instance_exec(object, &block) if block
      object
    end
  end

  # Declares stubbed constant named as classified version of
  # +const_prefix+_+name memo+ as a memo by using the
  # +let(name + '_' + memo_suffix)+ method.
  # @param name [String, Symbol]
  # @param memo_suffix [String, Symbol]
  # @param const_prefix [String, Symbol]
  # @param block [Proc] that will be executed in the example's context
  def let_stub_const(name, memo_suffix: :object, const_prefix: :example, &block)
    let(:"#{name}_#{memo_suffix}") do |ex|
      stub_const inflector.classify("#{const_prefix}_#{name}"), ex.instance_exec(ex, &block)
    end
  end
end
