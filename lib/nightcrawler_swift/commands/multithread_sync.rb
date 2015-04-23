module NightcrawlerSwift
  class MultithreadSync < Command
    DEFAULT_POOL_SIZE = 5

    def initialize
      require 'concurrent/utilities'
      require 'concurrent/executors'
      @logger = NightcrawlerSwift.logger
    end

    def execute args = {}
      pool_size = args[:pool_size] || DEFAULT_POOL_SIZE
      dir_path = args[:dir_path]

      @logger.info "[NightcrawlerSwift] dir_path: #{dir_path}"
      @logger.info "[NightcrawlerSwift] multithread sync, #{Concurrent.processor_count} processors"

      assets = Dir["#{dir_path}/**/**"].
        reject {|fullpath| File.directory?(fullpath)}.
        map {|fullpath|
          path = fullpath.gsub("#{dir_path}/", "")
          OpenStruct.new(path: path, fullpath: fullpath)
        }

      pool = Concurrent::FixedThreadPool.new pool_size

      assets.each do |asset|
        pool.post do
          @logger.info "[NightcrawlerSwift] #{asset.path}"

          upload = Upload.new
          upload.execute asset.path, File.open(asset.fullpath, "r")
        end
      end

      sleep(1) while pool.queue_length > 0

      @logger.info "[NightcrawlerSwift] shutting down"
      pool.shutdown
      pool.wait_for_termination
    end

  end
end
