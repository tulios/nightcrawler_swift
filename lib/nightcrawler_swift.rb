require "cgi"
require "date"
require "logger"
require "digest"
require "ostruct"
require "multi_mime"
require "rest_client"
require "nightcrawler_swift/version"
require "nightcrawler_swift/exceptions"
require "nightcrawler_swift/gateway"
require "nightcrawler_swift/connection"
require "nightcrawler_swift/command"
require "nightcrawler_swift/commands/upload"
require "nightcrawler_swift/commands/download"
require "nightcrawler_swift/commands/list"
require "nightcrawler_swift/commands/delete"
require "nightcrawler_swift/commands/sync"
require "nightcrawler_swift/railtie" if defined?(Rails)

module NightcrawlerSwift
  class << self

    attr_accessor :logger
    attr_reader :options, :connection

    def logger
      @logger ||= Logger.new(STDOUT).tap {|l| l.level = Logger::INFO}
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
    # - retries (default: 3)
    # - max_retry_time (in seconds, default: 30)
    #
    def configure opts = {}
      defaults = {verify_ssl: false, retries: 5, max_retry_time: 30}
      @options = OpenStruct.new(defaults.merge(opts))

      if @options.max_age and not @options.max_age.is_a?(Numeric)
        raise Exceptions::ConfigurationError.new "max_age should be an Integer"
      end

      @connection = Connection.new
    end

    def sync dir_path
      Sync.new.execute(dir_path)
    end

  end
end
