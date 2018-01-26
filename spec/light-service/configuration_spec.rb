require 'spec_helper'

RSpec.describe LightService::Configuration do
  describe "::raise_unused_key_error?" do
    it "defaults to false" do
      expect(described_class.raise_unused_key_error?).to eq false
    end

    it "can toggle" do
      described_class.raise_unused_key_error = true

      expect { described_class.raise_unused_key_error = false }.to(
        change { described_class.raise_unused_key_error? }.from(true).to(false)
      )
    end

    context "when set to false" do
      it "is false" do
        described_class.raise_unused_key_error = false
        expect(described_class.raise_unused_key_error?).to eq false
      end
    end

    context "when set to true" do
      it "is true" do
        described_class.raise_unused_key_error = true
        expect(described_class.raise_unused_key_error?).to eq true
      end
    end
  end
end
