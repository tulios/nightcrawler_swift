module NightcrawlerSwift
  module Exceptions

    class BaseError < StandardError
      attr_accessor :original_exception

      def initialize exception
        @original_exception = exception
      end
    end

    class ConnectionError < BaseError; end

  end
end
