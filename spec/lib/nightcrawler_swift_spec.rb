require "spec_helper"

describe NightcrawlerSwift do

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
    it "creates a new connection with the given opts" do
      opts = {bucket: "rogue"}
      expect(NightcrawlerSwift::Connection).to receive(:new).with(opts).and_call_original
      subject.configure opts
      expect(subject.connection).to_not be_nil
    end
  end

  describe "::connection" do
    it "returns the configured connection" do
      connection = NightcrawlerSwift::Connection.new
      expect(NightcrawlerSwift::Connection).to receive(:new).with(anything).and_return(connection)
      NightcrawlerSwift.configure
      expect(NightcrawlerSwift.connection).to eql(connection)
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

    it "connects" do
      allow(NightcrawlerSwift::Sync).to receive(:new).and_return(sync_instance)
      expect(NightcrawlerSwift.connection).to receive(:connect!)
      NightcrawlerSwift.sync dir_path
    end

    it "uses Sync command with the given dir_path" do
      expect(NightcrawlerSwift.connection).to receive(:connect!)
      expect(NightcrawlerSwift::Sync).to receive(:new).and_return(sync_instance)
      expect(sync_instance).to receive(:execute).with(dir_path)
      NightcrawlerSwift.sync dir_path
    end
  end

end
