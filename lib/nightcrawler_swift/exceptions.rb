module NightcrawlerSwift
  module Exceptions

    class BaseError < StandardError
      attr_accessor :original_exception

      def initialize exception
        super(exception.is_a?(String) ? exception : exception.message)
        @original_exception = exception
      end
    end

    class ConnectionError < BaseError; end
    class ValidationError < ConnectionError; end
    class NotFoundError < BaseError; end
    class ConfigurationError < StandardError; end
  end
end
