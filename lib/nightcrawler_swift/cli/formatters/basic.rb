module NightcrawlerSwift::CLI
  module Formatters
    class Basic

      def initialize runner
        @runner = runner
      end

      def command_list command
        array = command.new.execute
        array.each {|hash| @runner.log hash["name"]}
      end

      def command_download command
        filepath = @runner.argv.first
        @runner.log command.new.execute(filepath)
      end

      def command_upload command
        realpath = @runner.argv.shift
        swiftpath = @runner.argv.shift

        uploaded = command.new.execute swiftpath, File.open(File.expand_path(realpath), "r")
        @runner.log(uploaded ? "success" : "failure")
      end

      def command_delete command
        filepath = @runner.argv.first
        deleted = command.new.execute(filepath).to_json
        @runner.log(deleted ? "success" : "failure")
      end

      def command_url_for command
        filepath = @runner.argv.first
        @runner.log command.new.execute(filepath)
      end

    end
  end
end
