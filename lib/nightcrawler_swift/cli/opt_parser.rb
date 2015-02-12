module NightcrawlerSwift::CLI
  class OptParser

    attr_reader :parser

    def initialize runner
      @runner = runner
      @parser = OptionParser.new
      configure_instructions
      configure_options
    end

    def parse!
      @parser.parse!(@runner.argv)
    end

    def help
      @parser.help
    end

    private
    def configure_instructions
      @parser.banner = "nswift #{NightcrawlerSwift::VERSION}"
      @parser.separator "Usage: nswift command [options]"
      @parser.separator ""
      @parser.separator "commands:"
      COMMANDS.keys.each do |key|
        @parser.separator "    #{key}\t\t\t     #{COMMANDS[key][:description]}"
      end

      @parser.separator ""
    end

    def configure_options
      @parser.separator "options:"
      configure_option_bucket
      configure_option_max_age
      configure_option_config
      configure_option_no_cache
      configure_option_help
      configure_option_version
    end

    def configure_option_bucket
      desc = "Alternative bucket/container name, overrides the '#{NightcrawlerSwift::CLI::CONFIG_FILE}' configuration"
      @parser.on("-b", "--bucket=NAME", String, desc) do |name|
        bucket = name.strip
        @runner.options.config_hash[:bucket] = bucket
        @runner.log "Using bucket: #{bucket}"
      end
    end

    def configure_option_max_age
      desc = "Custom max_age value, it overrides the value configured at '#{NightcrawlerSwift::CLI::CONFIG_FILE}'"
      @parser.on("--max-age=VALUE", String, desc) do |value|
        max_age = value.strip.to_i
        @runner.options.config_hash[:max_age] = max_age
        @runner.log "Using max_age: #{max_age}"
      end
    end

    def configure_option_config
      @parser.on("-c", "--config=PATH", String, "Alternative '#{NightcrawlerSwift::CLI::CONFIG_FILE}' file") do |path|
        path = File.expand_path(path.strip)

        unless File.exist?(path)
          @runner.log "Error: No such file or directory - #{path}"
          exit 1
        end

        @runner.log "Using custom config file at: #{path}"
        @runner.options.config_file = path
        @runner.options.default_config_file = false
      end
    end

    def configure_option_no_cache
      @parser.on_tail("--no-cache", "Avoids the connection cache. It also clears the cache if it exists") do
        @runner.options.use_cache = false
      end
    end

    def configure_option_help
      @parser.on_tail("-h", "--help", "Show this message") do
        @runner.log help
        exit
      end
    end

    def configure_option_version
      @parser.on_tail("-v", "--version", "Show version") do
        @runner.log NightcrawlerSwift::VERSION
        exit
      end
    end

  end
end
