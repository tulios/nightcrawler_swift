require "cgi"
require "date"
require "logger"
require "digest"
require "ostruct"
require "multi_mime"
require "rest_client"
require "nightcrawler_swift/version"
require "nightcrawler_swift/exceptions"
require "nightcrawler_swift/ext/hash"
require "nightcrawler_swift/ext/open_struct"
require "nightcrawler_swift/ext/nil_class"
require "nightcrawler_swift/options"
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
    # - timeout (in seconds. Optional, default: nil)
    #
    # - retries (default: 3)
    # - max_retry_time (in seconds, default: 30)
    #
    # - verify_ssl (optional, default: false)
    # - ssl_client_cert (optional, default: nil)
    # - ssl_client_key (optional, default: nil)
    # - ssl_ca_file (optional, default: nil)
    #
    def configure opts = {}
      opts.symbolize_keys!
      @options = Options.new opts
      @connection = Connection.new
    end

    def sync dir_path
      Sync.new.execute(dir_path)
    end

  end
end
