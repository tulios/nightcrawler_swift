module NightcrawlerSwift::CLI
  class Runner
    attr_reader :opt_parser, :options
    attr_accessor :argv

    def initialize argv
      @argv = argv
      configure_logger
    end

    def run
      configure_default_options
      configure_opt_parser
      parse_parameters
      @command_name = argv.shift
      validate_command_and_options
      execute_command if @command_name
    end

    def log string
      NightcrawlerSwift.logger.info string
    end

    protected
    def user_home_dir
      Dir.home
    end

    private
    def configure_logger
      STDOUT.sync = true
      NightcrawlerSwift.logger.formatter = lambda {|severity, datetime, progname, msg| "#{msg}\n"}
    end

    def configure_default_options
      @options = OpenStruct.new
      @options.configured = true
      @options.default_config_file = true
      @options.config_file = File.expand_path(File.join(user_home_dir, CONFIG_FILE))
      @options.cache_file = File.expand_path(File.join(user_home_dir, CACHE_FILE))
      @options.command = nil
    end

    def validate_command_and_options
      if @command_name.nil? or argv.nil?
        log @opt_parser.help
        exit
      end

      unless options.configured
        log "You must configure your swift credentials, take a look at:\n   #{options.config_file}"
        exit
      end
    end

    def config_hash
      @config_hash ||= JSON.parse(File.read(options.config_file))

    rescue Errno::ENOENT => e
      log "No such file or directory - #{options.config_file}"
      exit 1
    end

    def execute_command
      NightcrawlerSwift.configure config_hash
      connect_and_execute do
        if command = COMMANDS[@command_name]
          command_module = command[:command]
          command_method = "command_#{@command_name}"
          Formatters::Basic.new(self).send(command_method, command_module)
        end
      end

    rescue NightcrawlerSwift::Exceptions::BaseError => e
      log e.message
      exit 1
    end

    def connect_and_execute &block
      path = options.cache_file
      if File.exist?(path)
        hash = JSON.parse File.read(path)
        NightcrawlerSwift.connection.auth_response = OpenStruct.new(hash)
        NightcrawlerSwift.connection.configure
      end

      begin
        block.call
      ensure
        File.open(path, "w") do |f|
          f.write(NightcrawlerSwift.connection.auth_response.to_h.to_json)
        end
      end
    end

    def parse_parameters
      @opt_parser.parse!
      check_rcfile if options.default_config_file

    rescue OptionParser::InvalidOption => e
      log e.message
      exit 1
    end

    def configure_opt_parser
      @opt_parser = OptParser.new self
    end

    def check_rcfile
      sample = NightcrawlerSwift::CLI.sample_rcfile
      unless File.exist?(options.config_file)
        File.open(options.config_file, "w") { |f|
          f.write(sample)
        }
      end

      if sample == File.read(options.config_file)
        options.configured = false
      end
    end

  end
end
