require "spec_helper"
require "nightcrawler_swift/cli"

describe NightcrawlerSwift::CLI::OptParser do

  let :runner do
    instance_double "Runner", options: OpenStruct.new(config_file: nil)
  end

  let :config_dir do
    File.expand_path(File.join(File.dirname(__FILE__), "../../../fixtures"))
  end

  subject do
    NightcrawlerSwift::CLI::OptParser.new runner
  end

  context "--version or -v" do
    it "prints the version number" do
      allow(runner).to receive(:argv).and_return(["-v"])
      expect(runner).to receive(:log).with(NightcrawlerSwift::VERSION)
      expect { subject.parse! runner.argv }.to raise_error SystemExit

      allow(runner).to receive(:argv).and_return(["--version"])
      expect(runner).to receive(:log).with(NightcrawlerSwift::VERSION)
      expect { subject.parse! runner.argv }.to raise_error SystemExit
    end
  end

  context "--help or -h" do
    it "prints the help" do
      allow(runner).to receive(:argv).and_return(["-h"])
      expect(runner).to receive(:log).with(subject.help)
      expect { subject.parse! runner.argv }.to raise_error SystemExit

      allow(runner).to receive(:argv).and_return(["--help"])
      expect(runner).to receive(:log).with(subject.help)
      expect { subject.parse! runner.argv }.to raise_error SystemExit
    end
  end

  context "--config or -c" do
    let :config_file do
      File.join(config_dir, "#{NightcrawlerSwift::CLI::CONFIG_FILE}-test")
    end

    before do
      allow(runner).to receive(:log)
      File.open(config_file, "w") {|f| f.write("test")}
    end

    after do
      File.delete(config_file) if File.exist?(config_file)
    end

    it "configures the config_file" do
      allow(runner).to receive(:argv).and_return(["-c #{config_file}"])
      subject.parse! runner.argv
      expect(runner.options.config_file).to eql config_file

      allow(runner).to receive(:argv).and_return(["--config=#{config_file}"])
      subject.parse! runner.argv
      expect(runner.options.config_file).to eql config_file
    end
  end

end
