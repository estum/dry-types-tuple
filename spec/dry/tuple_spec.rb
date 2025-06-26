# frozen_string_literal: true

module Dry
  RSpec.describe Tuple do
    it "has a version number" do
      expect(described_class::VERSION).not_to be nil
    end

    describe ".loader" do
      subject(:loader) { described_class.loader }

      it { is_expected.to be_instance_of(Zeitwerk::Loader) }

      it "doesn't raise an error on eager load" do
        expect { loader.eager_load(force: true) }.not_to raise_error
      end
    end
  end
end