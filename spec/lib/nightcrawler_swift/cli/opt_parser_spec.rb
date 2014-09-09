require "spec_helper"
require "nightcrawler_swift/cli"

describe NightcrawlerSwift::CLI::OptParser do

  let :runner do
    instance_double "Runner", options: OpenStruct.new(bucket: nil, config_file: nil, default_config_file: true)
  end

  let :config_dir do
    File.expand_path(File.join(File.dirname(__FILE__), "../../../fixtures"))
  end

  subject do
    NightcrawlerSwift::CLI::OptParser.new runner
  end

  describe "options" do

    ["-v", "--version"].each do |switch|
      context switch do
        it "prints the version number" do
          allow(runner).to receive(:argv).and_return([switch])
          expect(runner).to receive(:log).with(NightcrawlerSwift::VERSION)
          expect { subject.parse! }.to raise_error SystemExit
        end
      end
    end

    ["-h", "--help"].each do |switch|
      context switch do
        it "prints the help" do
          allow(runner).to receive(:argv).and_return([switch])
          expect(runner).to receive(:log).with(subject.help)
          expect { subject.parse! }.to raise_error SystemExit
        end
      end
    end

    ["-c PATH", "--config=PATH"].each do |switch|
      context switch do
        let :config_file do
          File.join(config_dir, "#{NightcrawlerSwift::CLI::CONFIG_FILE}-test")
        end

        let :command do
          switch.gsub(/PATH/, config_file)
        end

        before do
          File.open(config_file, "w") {|f| f.write("test")}
        end

        after do
          File.delete(config_file) if File.exist?(config_file)
        end

        it "configures the config_file" do
          allow(runner).to receive(:log)
          allow(runner).to receive(:argv).and_return([command])
          subject.parse!
          expect(runner.options.config_file).to eql config_file
          expect(runner.options.default_config_file).to eql false
        end

        context "when the config file does not exist" do
          let :invalid_filename do
            "invalid-file"
          end

          let :invalid_filepath do
            File.expand_path(File.join(File.dirname(__FILE__), "../../../../", invalid_filename))
          end

          let :command do
            switch.gsub(/PATH/, invalid_filename)
          end

          it "prints the error and exit with a failure" do
            expect(runner).to receive(:argv).and_return([command])
            expect(runner).to receive(:log).with("Error: No such file or directory - #{invalid_filepath}")
            exited = false

            begin
              subject.parse!
            rescue SystemExit => e
              exited = true
              expect(e.status).to eql 1
            ensure
              expect(exited).to eql true
            end
          end
        end
      end
    end

    ["-b NAME", "--bucket=NAME"].each do |switch|
      context switch do
        let :bucket_name do
          "rogue"
        end

        let :command do
          switch.gsub(/NAME/, bucket_name)
        end

        it "configures the bucket name" do
          allow(runner).to receive(:argv).and_return([command])
          allow(runner).to receive(:log)
          subject.parse!
          expect(runner.options.bucket).to eql bucket_name
        end
      end
    end
  end

  describe "#parse!" do
    before do
      allow(runner).to receive(:argv).and_return([])
    end

    it "calls method 'parse!' in OptionParser with runner argv" do
      expect(subject.parser).to receive(:parse!).with(runner.argv)
      subject.parse!
    end
  end

  describe "#help" do
    it "calls method 'help' in OptionParser" do
      expect(subject.parser).to receive(:help)
      subject.help
    end
  end

end
