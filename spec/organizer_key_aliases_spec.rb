require 'spec_helper'
require 'test_doubles'

describe "organizer aliases macro" do
  let(:organizer_with_alias) do
    Class.new do
      extend LightService::Organizer

      aliases :promised_key => :expected_key

      def self.do_something(ctx = {})
        with(ctx).reduce(
          [
            TestDoubles::PromisesPromisedKeyAction,
            TestDoubles::ExpectsExpectedKeyAction
          ]
        )
      end
    end
  end

  context "when aliases is invoked" do
    it "makes aliases available to the actions" do
      result = organizer_with_alias.do_something
      expect(result[:expected_key]).to eq(result[:promised_key])
      expect(result.expected_key).to eq(result[:promised_key])
    end
  end

  context "when an aliased key is updated" do
    let(:organizer_with_alias) do
      Class.new do
        extend LightService::Organizer

        aliases :promised_key => :expected_key

        def self.do_something(ctx = {})
          with(ctx).reduce(
            [
              TestDoubles::PromisesPromisedKeyAction,
              TestDoubles::DoublesExpectedKeyAction
            ]
          )
        end
      end
    end

    it "the original and aliased key return the same value" do
      result = organizer_with_alias.do_something
      expect(result[:expected_key]).to eq(result[:promised_key])
      expect(result.expected_key).to eq(result[:promised_key])
    end
  end

  context "when an aliased key is typo'd" do
    let(:organizer_with_alias) do
      Class.new do
        extend LightService::Organizer

        aliases :promiser_key => :expected_key

        def self.do_something(ctx = {})
          with(ctx).reduce(
            [
              TestDoubles::PromisesPromisedKeyAction,
              TestDoubles::ExpectsExpectedKeyAction
            ]
          )
        end
      end
    end

    it "raises an ExpectedKeysNotInContextError" do
      # This is a non-obvious test.  The Organizer class is aliasing promiser_key to expected_key, but the
      # PromisesPromisedKeyAction is setting promised_key in the context.  We should catch that expected_key
      # dereferences to a non-existent key.
      expect(organizer_with_alias.do_something).to raise_error(LightService::ExpectedKeysNotInContextError)
    end
  end
end
