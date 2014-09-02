require "optparse"
require "json"

module NightcrawlerSwift
  class CLI
    CONFIG_FILE = ".nswiftrc"
    CACHE_FILE = ".nswift_cache"
    COMMANDS = {
      "list" => {
        description: "List all files of the bucket/container. Ex: nswift list",
        command: NightcrawlerSwift::List
      },

      "download" => {
        description: "Download a file by path, Ex: nswift download assets/robots.txt > my-robots.txt",
        command: NightcrawlerSwift::Download
      }
    }

    attr_reader :opt_parser, :options
    attr_accessor :argv

    def initialize argv
      @argv = argv
      STDOUT.sync = true
      NightcrawlerSwift.logger.formatter = lambda {|severity, datetime, progname, msg| "#{msg}\n"}
    end

    def run
      configure_default_options
      parse_parameters
      @command_name = argv.shift
      validate_command_and_options
      execute_command if @command_name
    end

    protected
    def command_list command
      array = command.new.execute
      array.each {|hash| log hash["name"]}
    end

    def command_download command
      filepath = argv.first
      log command.new.execute(filepath)
    end

    def user_home_dir
      Dir.home
    end

    def log string
      NightcrawlerSwift.logger.info string
    end

    private
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
        log opt_parser.help
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
          self.send(command_method, command_module)
        end
      end

    rescue Exceptions::BaseError => e
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
      configure_opt_parser
      opt_parser.parse!(argv)
      check_rcfile if options.default_config_file

    rescue OptionParser::InvalidOption => e
      log e.message
      exit 1
    end

    def configure_opt_parser
      @opt_parser = OptionParser.new do |opts|
        opts.banner = "nswift #{NightcrawlerSwift::VERSION}"
        opts.separator "Usage: nswift command [options]"

        opts.separator ""
        opts.separator "commands:"
        COMMANDS.keys.each do |key|
          opts.separator "    #{key}\t\t\t     #{COMMANDS[key][:description]}"
        end

        opts.separator ""
        opts.separator "options:"

        opts.on("-c", "--config=PATH", String, "Alternative '#{CONFIG_FILE}' file") do |path|
          path = File.expand_path(path.strip)
          log "Using custom config file at: #{path}"
          options.config_file = path
          options.default_config_file = false
        end

        opts.on_tail("-h", "--help", "Show this message") do
          log opts.help
          exit
        end

        opts.on_tail("-v", "--version", "Show version") do
          log NightcrawlerSwift::VERSION
          exit
        end
      end
    end

    def check_rcfile
      unless File.exist?(options.config_file)
        File.open(options.config_file, "w") { |f|
          f.write(sample_rcfile)
        }
      end

      if sample_rcfile == File.read(options.config_file)
        options.configured = false
      end
    end

    def sample_rcfile
      JSON.pretty_generate({
        bucket: "<bucket/container name>",
        tenant_name: "<tenant name>",
        username: "<username>",
        password: "<password>",
        auth_url: "<auth url, ex: https://auth.url.com:123/v2.0/tokens>"
      })
    end

  end
end
