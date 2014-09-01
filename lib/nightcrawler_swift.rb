require "date"
require "logger"
require "ostruct"
require "multi_mime"
require "rest_client"
require "nightcrawler_swift/version"
require "nightcrawler_swift/exceptions"
require "nightcrawler_swift/command"
require "nightcrawler_swift/connection"
require "nightcrawler_swift/upload"
require "nightcrawler_swift/download"
require "nightcrawler_swift/list"
require "nightcrawler_swift/delete"
require "nightcrawler_swift/sync"
require "nightcrawler_swift/railtie" if defined?(Rails)

module NightcrawlerSwift
  class << self

    attr_accessor :logger
    attr_reader :options, :connection

    def logger
      @logger || Logger.new(STDOUT)
    end

    # Hash with:
    # - bucket
    # - tenant_name
    # - username
    # - password
    # - auth_url
    #
    # - max_age (optional, default: nil)
    # - verify_ssl (optional, default: false)
    # - timeout (in seconds. Optional, default: nil)
    #
    def configure opts = {}
      @options = OpenStruct.new({verify_ssl: false}.merge(opts))

      if @options.max_age and not @options.max_age.is_a?(Numeric)
        raise Exceptions::ConfigurationError.new "max_age should be an Integer"
      end

      @connection = Connection.new
    end

    def sync dir_path
      connection.connect!
      Sync.new.execute(dir_path)
    end

  end
end
