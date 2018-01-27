require 'spec_helper'

RSpec.describe LightService::Configuration do
  describe "unused key error action" do
    it "ignores errors by default" do
      expect(described_class.ignore_unused_key_error?).to be true
      expect(described_class.raise_unused_key_error?).to be false
      expect(described_class.warn_on_unused_key_error?).to be false
    end

    context "when set to ignore" do
      it "ignores errors" do
        described_class.action_on_unused_key_error = :ignore
        expect(described_class.ignore_unused_key_error?).to be true
        expect(described_class.raise_unused_key_error?).to be false
        expect(described_class.warn_on_unused_key_error?).to be false
      end
    end

    context "when set to warn" do
      it "warns of errors" do
        described_class.action_on_unused_key_error = :warn
        expect(described_class.ignore_unused_key_error?).to be false
        expect(described_class.raise_unused_key_error?).to be false
        expect(described_class.warn_on_unused_key_error?).to be true
      end
    end

    context "when set to raise" do
      it "raises errors" do
        described_class.action_on_unused_key_error = :raise
        expect(described_class.ignore_unused_key_error?).to be false
        expect(described_class.raise_unused_key_error?).to be true
        expect(described_class.warn_on_unused_key_error?).to be false
      end
    end
  end
end
