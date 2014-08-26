module NightcrawlerSwift
  class Sync

    def initialize connection
      @connection = connection
    end

    def execute dir_path
      upload = Upload.new @connection

      NightcrawlerSwift.logger.info "dir_path: #{dir_path}"
      entries = Dir["#{dir_path}/**/**"]
      entries.each do |entry_fullpath|
        entry_path = entry_fullpath.gsub(dir_path, "")
        unless File.directory?(entry_fullpath)
          NightcrawlerSwift.logger.info entry_path
          upload.execute entry_path, File.open(entry_fullpath, "r")
        end
      end
    end

  end
end
