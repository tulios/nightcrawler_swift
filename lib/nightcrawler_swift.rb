require "ostruct"
require "nightcrawler_swift/version"
require "nightcrawler_swift/connection"
require "nightcrawler_swift/upload"

module NightcrawlerSwift

  def self.configure opts = {}
    @connection = Connection.new opts
  end

  def self.sync dir_path
    @connection.connect!

    service = Upload.new @connection

    entries = Dir["#{path}/**/**"]
    entries.each do |entry_fullpath|
      entry_path = entry_fullpath.gsub(path, "")
      if File.directory?(entry_fullpath)
        # directory = service.directories.create :key => directory_name, :public => true

      else
        puts entry_path
        service.upload entry_path, File.open(entry_fullpath, "r")
      end
    end
  end

end
