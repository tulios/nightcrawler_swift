require "spec_helper"

describe NightcrawlerSwift do

  let(:opts) { {bucket: "rogue"} }

  subject do
    NightcrawlerSwift
  end

  describe "::logger" do
    before do
      subject.logger = nil
    end

    context "when not configured" do
      it "returns an instance of Logger with INFO level" do
        expect(Logger).to receive(:new).with(STDOUT).and_call_original
        subject.logger
        expect(subject.logger.level).to eql(Logger::INFO)
      end
    end

    it "returns the configured logger" do
      logger = Logger.new(StringIO.new)
      subject.logger = logger
      expect(subject.logger).to eql(logger)
    end
  end

  describe "::configure" do
    it "creates the options with the given values" do
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
      opts.keys.each do |key|
        expect(NightcrawlerSwift.options).to respond_to key
      end
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
