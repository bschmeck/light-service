require 'spec_helper'
require 'test_doubles'

describe ":expects macro" do
  context "when expected keys are in the context" do
    it "can access the keys as class methods" do
      resulting_context = TestDoubles::MakesTeaWithMilkAction.execute(
        :tea => "black",
        :milk => "full cream",
        :something => "else"
      )
      expect(resulting_context[:milk_tea]).to eq("black - full cream")
    end
  end

  context "when an expected key is marked as maybe" do
    it "can access the keys as class methods" do
      resulting_context = TestDoubles::MakesTeaMaybeWithMilkAction.execute(
        :tea => "black",
        :use_milk => true,
        :milk => "full cream"
      )
      expect(resulting_context[:milk_tea]).to eq("black - full cream")
    end
  end

  context "when all expected keys are marked as maybe" do
    it "can access the keys as class methods" do
      resulting_context = TestDoubles::MakesTeaWithMilkAllMaybesAction.execute(
        :tea => "black",
        :milk => "full cream",
        :something => "else"
      )
      expect(resulting_context[:milk_tea]).to eq("black - full cream")
    end
  end

  context "when an expected key is not in the context" do
    it "raises an LightService::ExpectedKeysNotInContextError" do
      exception_msg = "expected :milk to be in the context during " \
                      "TestDoubles::MakesTeaWithMilkAction"
      expect do
        TestDoubles::MakesTeaWithMilkAction.execute(:tea => "black")
      end.to \
        raise_error(LightService::ExpectedKeysNotInContextError, exception_msg)
    end
  end

  context "when the `expects` macro is called multiple times" do
    it "can collect expected keys " do
      result = TestDoubles::MultipleExpectsAction.execute(
        :tea => "black",
        :milk => "full cream",
        :chocolate => "dark chocolate"
      )
      expect(result[:milk_tea]).to \
        eq("black - full cream - with dark chocolate")
    end

    it "can mark multiple keys as maybe" do
      class MultipleMaybeAction
        extend LightService::Action
        expects :foo, :bar, :maybe => :foo
        expects :one, :two, :maybe => %i[one two]
      end

      expect(MultipleMaybeAction.maybe_keys).to match_array %i[foo one two]
    end
  end

  context "when an expected key is not used" do
    it "doesn't raise a LightService::ExpectedKeysNotUsedError" do
      expect do
        TestDoubles::MakesTeaMaybeWithMilkAction.execute(
          :tea => "black",
          :use_milk => false,
          :milk => nil
        )
      end.to_not raise_error
    end

    context "when configured to raise errors" do
      around(:each) do |example|
        LightService::Configuration.action_on_unused_key_error = :raise
        example.run
        LightService::Configuration.action_on_unused_key_error = :ignore
      end

      it "raises a LightService::ExpectedKeysNotUsedError" do
        exception_msg = "Expected keys [:milk] to be used during " \
                        "TestDoubles::MakesTeaWithoutMilkAction"
        expect do
          TestDoubles::MakesTeaWithoutMilkAction.execute(
            :tea => "black",
            :milk => "full cream"
          )
        end.to \
          raise_error(LightService::ExpectedKeysNotUsedError, exception_msg)
      end

      context "when the unused key is marked as maybe" do
        it "doesn't raise a LightService::ExpectedKeysNotUsedError" do
          expect do
            TestDoubles::MakesTeaMaybeWithMilkAction.execute(
              :tea => "black",
              :use_milk => false,
              :milk => nil
            )
          end.to_not raise_error
        end
      end
    end

    context "when configured to issue warnings" do
      around(:each) do |example|
        LightService::Configuration.action_on_unused_key_error = :warn
        example.run
        LightService::Configuration.action_on_unused_key_error = :ignore
      end

      it "issues a deprecation warning" do
        warning_msg = "Expected keys [:milk] to be used during " \
                      "TestDoubles::MakesTeaWithoutMilkAction.  " \
                      "This will raise an exception in future "\
                      "versions of LightService."
        expect(ActiveSupport::Deprecation).to receive(:warn).with(warning_msg)
        TestDoubles::MakesTeaWithoutMilkAction.execute(
          :tea => "black",
          :milk => "full cream"
        )
      end

      context "when the unused key is marked as maybe" do
        it "doesn't issue a warning" do
          expect(ActiveSupport::Deprecation).to_not receive(:warn)
          TestDoubles::MakesTeaMaybeWithMilkAction.execute(
            :tea => "black",
            :use_milk => false,
            :milk => nil
          )
        end
      end
    end
  end

  context "when a reserved key is listed as an expected key" do
    it "raises an error indicating a reserved key is expected" do
      exception_msg = "promised or expected keys cannot be a reserved key: " \
                      "[:message]"
      expect do
        TestDoubles::MakesTeaExpectingReservedKey.execute(:tea => "black",
                                                          :message => "no no")
      end.to \
        raise_error(LightService::ReservedKeysInContextError, exception_msg)
    end

    it "raises an error indicating that multiple reserved keys are expected" do
      exception_msg = "promised or expected keys cannot be a reserved key: " \
                      "[:message, :error_code, :current_action]"
      expect do
        TestDoubles::MakesTeaExpectingMultipleReservedKeys
          .execute(:tea => "black",
                   :message => "no no",
                   :error_code => 1,
                   :current_action => "update")
      end.to raise_error(LightService::ReservedKeysInContextError,
                         exception_msg)
    end
  end
end
