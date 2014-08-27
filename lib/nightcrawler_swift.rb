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
    attr_reader :connection

    def logger
      @logger || Logger.new(STDOUT)
    end

    def configure opts = {}
      @connection = Connection.new opts
    end

    def sync dir_path
      connection.connect!
      Sync.new.execute(dir_path)
    end

  end
end
