module LightService
  class Configuration
    class << self
      attr_accessor :capture_errors
      attr_writer :logger, :localization_adapter

      def logger
        @logger ||= _default_logger
      end

      def localization_adapter
        @localization_adapter ||= LocalizationAdapter.new
      end

      def raise_unused_key_error?
        @action_on_unused_key_error == :raise
      end

      def warn_on_unused_key_error?
        @action_on_unused_key_error == :warn
      end

      def ignore_unused_key_error?
        @action_on_unused_key_error.nil? ||
          @action_on_unused_key_error == :ignore
      end

      def action_on_unused_key_error=(value)
        unless %i[ignore raise warn].include? value
          raise ArgumentError, "Unsupported action #{value}"
        end
        @action_on_unused_key_error = value
      end

      private

      def _default_logger
        logger = Logger.new("/dev/null")
        logger.level = Logger::WARN
        logger
      end
    end
  end
end
