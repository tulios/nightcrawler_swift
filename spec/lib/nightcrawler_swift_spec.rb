require "spec_helper"

describe NightcrawlerSwift do

  let(:opts) { {bucket: "rogue"} }
  let(:options) { OpenStruct.new(opts) }

  subject do
    NightcrawlerSwift
  end

  describe "::logger" do
    before do
      subject.logger = nil
    end

    it "returns an instance of Logger when not configured" do
      expect(Logger).to receive(:new).with(STDOUT)
      subject.logger
    end

    it "returns the configured logger" do
      logger = Logger.new(StringIO.new)
      subject.logger = logger
      expect(subject.logger).to eql(logger)
    end
  end

  describe "::configure" do
    it "creates the options struct with the given values" do
      subject.configure opts
      expect(subject.options).to_not be_nil
      opts.keys.each do |key|
        expect(subject.options.send(key)).to eql(opts[key])
      end
    end

    it "creates a new connection" do
      expect(NightcrawlerSwift::Connection).to receive(:new).and_call_original
      subject.configure opts
      expect(subject.connection).to_not be_nil
    end

    context "verify_ssl" do
      it "defauts to false" do
        expect(subject.options.verify_ssl).to eql false
      end
    end

    context "and max_age isn't an integer" do
      let(:opts) { {max_age: "a string"} }

      it "raises NightcrawlerSwift::Exceptions::ConfigurationError" do
        expect { subject.configure(opts) }.to raise_error(NightcrawlerSwift::Exceptions::ConfigurationError)
      end
    end
  end

  describe "::connection" do
    it "returns the configured connection" do
      connection = NightcrawlerSwift::Connection.new
      expect(NightcrawlerSwift::Connection).to receive(:new).and_return(connection)
      NightcrawlerSwift.configure opts
      expect(NightcrawlerSwift.connection).to eql(connection)
    end
  end

  describe "::options" do
    before do
      allow(NightcrawlerSwift::Connection).to receive(:new)
    end

    it "returns the given options" do
      NightcrawlerSwift.configure(opts)
      expect(NightcrawlerSwift.options).to eql(OpenStruct.new(opts.merge(verify_ssl: false)))
    end
  end

  describe "::sync" do
    let :dir_path do
      "path"
    end

    let :sync_instance do
      double("Sync", execute: true)
    end

    before do
      NightcrawlerSwift.configure
    end

    it "uses Sync command with the given dir_path" do
      expect(NightcrawlerSwift::Sync).to receive(:new).and_return(sync_instance)
      expect(sync_instance).to receive(:execute).with(dir_path)
      NightcrawlerSwift.sync dir_path
    end
  end

end
