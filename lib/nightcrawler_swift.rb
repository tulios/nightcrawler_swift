require "ostruct"
require "rest_client"
require "nightcrawler_swift/version"
require "nightcrawler_swift/connection"
require "nightcrawler_swift/upload"
require "nightcrawler_swift/list"
require "nightcrawler_swift/delete"
require "nightcrawler_swift/sync"

module NightcrawlerSwift
  class << self

    attr_accessor :logger

    def logger
      @logger || Logger.new(STDOUT)
    end

    def connection
      @connection
    end

    def configure opts = {}
      @connection = Connection.new opts
    end

    def sync dir_path
      Sync.new(@connection.connect!).execute(dir_path)
    end

  end
end
