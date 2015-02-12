require "spec_helper"
require "nightcrawler_swift/cli"

describe NightcrawlerSwift::CLI::Runner do

  let :config_dir do
    File.expand_path(File.join(File.dirname(__FILE__), "../../../fixtures"))
  end

  let :config_file do
    File.join(config_dir, NightcrawlerSwift::CLI::CONFIG_FILE)
  end

  let :cache_file do
    File.join(config_dir, NightcrawlerSwift::CLI::CACHE_FILE)
  end

  let :connection_success_json do
    JSON.parse File.read(File.join(config_dir, "auth_success.json"))
  end

  let :formatter do
    NightcrawlerSwift::CLI::Formatters::Basic.new(subject)
  end

  let :filepath do
    "testfile.txt"
  end

  let :opts do
    {
      "bucket"      => "my-bucket-name",
      "tenant_name" => "tenant_username1",
      "username"    => "username1",
      "password"    => "some-pass",
      "auth_url"    => "https://auth-url-com:123/v2.0/tokens"
    }
  end

  subject do
    NightcrawlerSwift::CLI::Runner.new argv.dup
  end

  before do
    allow(Dir).to receive(:home).and_return(config_dir)
    allow(NightcrawlerSwift::CLI::Formatters::Basic).to receive(:new).and_return(formatter)
  end

  after do
    File.delete(config_file) if File.exist?(config_file)
    File.delete(cache_file) if File.exist?(cache_file)
  end

  shared_examples "CLI with default options" do
    before do
      File.open(config_file, "w") {|f| f.write(opts.to_json)}
      allow(subject).to receive(:execute_command)
    end

    it "points to a config file in the user home dir" do
      subject.run
      path = File.join(config_dir, NightcrawlerSwift::CLI::CONFIG_FILE)
      expect(subject.options.config_file).to eql File.expand_path(path)
    end

    it "enables the use of cache" do
      subject.run
      expect(subject.options.use_cache).to eql true
    end

    it "points to a cache file in the user home dir" do
      subject.run
      path = File.join(config_dir, NightcrawlerSwift::CLI::CACHE_FILE)
      expect(subject.options.cache_file).to eql File.expand_path(path)
    end
  end

  shared_examples "CLI that creates a sample config file" do
    before do
      allow(subject).to receive(:execute_command)
      allow(subject).to receive(:log)
    end

    it "creates a sample config file" do
      expect(File.exist?(config_file)).to eql false
      expect { subject.run }.to raise_error SystemExit
      expect(File.exist?(config_file)).to eql true
      expect(File.read(config_file)).to eql NightcrawlerSwift::CLI.sample_rcfile
    end

    it "flags as not configured" do
      expect { subject.run }.to raise_error SystemExit
      expect(subject.options.configured).to eql false
    end
  end

  shared_examples "CLI that uses the configured command" do
    let :connection do
      NightcrawlerSwift::Connection.new
    end

    before do
      allow(formatter).to receive(command_method)
      allow(NightcrawlerSwift).to receive(:connection).and_return(connection)
      File.open(config_file, "w") {|f| f.write(opts.to_json)}
    end

    it "configures NightcrawlerSwift" do
      expect(NightcrawlerSwift).to receive(:configure).with opts.symbolize_keys
      subject.run
    end

    context "when exist a previous valid authorization" do
      it "reuses that" do
        File.open(cache_file, "w") {|f| f.write(connection_success_json.to_json)}
        expect(File.exist?(cache_file)).to eql true

        expect(connection).to receive(:configure).and_call_original
        subject.run
        # This test uses 'eq' instead of 'eql' because in Ruby 1.9.x the method
        # 'equal?' is different than '==' making this test fail
        expect(connection.auth_response).to eq(OpenStruct.new(connection_success_json))
      end
    end

    context "with a custom bucket name" do
      let(:bucket_name) { "rogue" }

      before do
        subject.send :configure_default_options
        expect(subject.options.config_hash).to eql({})
      end

      it "overrides the default name" do
        allow(subject).to receive(:parse_parameters) { subject.options.config_hash[:bucket] = bucket_name }
        subject.run
        expect(NightcrawlerSwift.options.bucket).to eql bucket_name
      end
    end

    context "with a custom max-age" do
      let(:max_age) { 300 }

      before do
        subject.send :configure_default_options
        expect(subject.options.config_hash).to eql({})
      end

      it "overrides the default name" do
        allow(subject).to receive(:parse_parameters) { subject.options.config_hash[:max_age] = max_age }
        subject.run
        expect(NightcrawlerSwift.options.max_age).to eql max_age
      end
    end

    context "with no-cache flag" do
      before do
        subject.send :configure_default_options
        expect(subject.options.use_cache).to eql true
        allow(subject).to receive(:parse_parameters) { subject.options.use_cache = false }
      end

      it "doesn't write the auth_response into cache file" do
        expect(File.exist?(cache_file)).to eql false
        allow(connection).to receive(:auth_response).and_return(OpenStruct.new(connection_success_json))
        subject.run
        expect(File.exist?(cache_file)).to eql false
      end

      it "removes the cache file if it exists" do
        expect(File.exist?(cache_file)).to eql false
        allow(connection).to receive(:auth_response).and_return(OpenStruct.new(connection_success_json))
        File.open(cache_file, "w") {|f| f.write(connection_success_json.to_json)}
        expect(File.exist?(cache_file)).to eql true
        subject.run
        expect(File.exist?(cache_file)).to eql false
      end
    end

    it "writes the auth_response into cache file" do
      expect(File.exist?(cache_file)).to eql false
      expect(connection).to receive(:auth_response).and_return(OpenStruct.new(connection_success_json))
      subject.run
      expect(File.exist?(cache_file)).to eql true
      expect(File.read(cache_file)).to eql connection_success_json.to_json
    end

    context "when rescue NightcrawlerSwift::Exceptions::BaseError" do
      let(:message) { "error" }

      before do
        NightcrawlerSwift.logger = Logger.new(StringIO.new)
      end

      it "prints the error and exit with failure" do
        expect(subject).to receive(:connect_and_execute).and_raise(NightcrawlerSwift::Exceptions::BaseError.new(message))
        exited = false

        begin
          subject.run
        rescue SystemExit => e
          exited = true
          expect(e.status).to eql 1
        ensure
          expect(exited).to eql true
        end
      end
    end

    context "when rescue Errno::ENOENT" do
      before do
        NightcrawlerSwift.logger = Logger.new(StringIO.new)
      end

      it "prints the error and exit with failure" do
        expect(subject).to receive(:connect_and_execute).and_raise(Errno::ENOENT.new)
        exited = false

        begin
          subject.run
        rescue SystemExit => e
          exited = true
          expect(e.status).to eql 1
        ensure
          expect(exited).to eql true
        end
      end
    end
  end

  describe "command list" do
    let(:argv) { ["list"] }
    let(:command) { NightcrawlerSwift::List.new }
    let(:command_method) { :command_list }

    it_behaves_like "CLI with default options"
    it_behaves_like "CLI that creates a sample config file"
    it_behaves_like "CLI that uses the configured command"
  end

  describe "command download" do
    let(:argv) { ["download", filepath] }
    let(:command) { NightcrawlerSwift::Download.new }
    let(:command_method) { :command_download }

    it_behaves_like "CLI with default options"
    it_behaves_like "CLI that creates a sample config file"
    it_behaves_like "CLI that uses the configured command"
  end

  describe "command upload" do
    let(:realpath) { File.join(config_dir, filepath) }
    let(:argv) { ["upload", realpath, filepath] }
    let(:command) { NightcrawlerSwift::Upload.new }
    let(:command_method) { :command_upload }

    it_behaves_like "CLI with default options"
    it_behaves_like "CLI that creates a sample config file"
    it_behaves_like "CLI that uses the configured command"
  end

  describe "command delete" do
    let(:argv) { ["delete", filepath] }
    let(:command) { NightcrawlerSwift::Delete.new }
    let(:command_method) { :command_delete }

    it_behaves_like "CLI with default options"
    it_behaves_like "CLI that creates a sample config file"
    it_behaves_like "CLI that uses the configured command"
  end

  describe "command delete" do
    let(:argv) { ["url-for", filepath] }
    let(:command) { NightcrawlerSwift::CLI::UrlFor.new }
    let(:command_method) { :command_url_for }

    it_behaves_like "CLI with default options"
    it_behaves_like "CLI that creates a sample config file"
    it_behaves_like "CLI that uses the configured command"
  end

  describe "validation of commands" do
    context "when no command is provided" do
      let(:argv) { [] }

      before do
        subject.send :configure_default_options
        subject.send :configure_opt_parser
      end

      it "prints the help and exit with success" do
        exited = false
        expect(subject).to receive(:log).with(subject.opt_parser.help)
        begin
          subject.run
        rescue SystemExit => e
          exited = true
          expect(e.status).to eql 0
        ensure
          expect(exited).to eql true
        end
      end
    end

    context "when the command does not exist" do
      let(:argv) { ["wrong"] }

      it "prints the error and exit with failure" do
        exited = false
        expect(subject).to receive(:log).with("Error: Unknown command 'wrong'")
        begin
          subject.run
        rescue SystemExit => e
          exited = true
          expect(e.status).to eql 1
        ensure
          expect(exited).to eql true
        end
      end
    end
  end

  describe "#log" do
    let(:argv) { [] }

    before do
      NightcrawlerSwift.logger = Logger.new(StringIO.new)
    end

    it "uses NightcrawlerSwift.logger" do
      expect(NightcrawlerSwift).to receive(:logger).and_call_original
      subject.log "stuff"
    end
  end

end
