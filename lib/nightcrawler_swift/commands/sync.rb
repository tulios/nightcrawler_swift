module NightcrawlerSwift
  class Sync < Command

    def initialize
      @upload = Upload.new
      @logger = NightcrawlerSwift.logger
    end

    def execute dir_path
      @logger.info "dir_path: #{dir_path}"
      Dir["#{dir_path}/**/**"].each do |fullpath|
        path = fullpath.gsub("#{dir_path}/", "")

        unless File.directory?(fullpath)
          @logger.info path
          @upload.execute path, File.open(fullpath, "r")
        end
      end
    end

  end
end
