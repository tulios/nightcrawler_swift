require "spec_helper"

describe NightcrawlerSwift::Sync do

  let(:connection) { NightcrawlerSwift::Connection.new }
  let(:token) { "token" }
  let(:expires_at) { (DateTime.now + 60).to_time }
  let(:upload_url) { "server-url" }

  subject do
    NightcrawlerSwift::Sync.new
  end

  before do
    NightcrawlerSwift.logger = Logger.new(StringIO.new)
    allow(NightcrawlerSwift).to receive(:connection).and_return(connection)
    allow(connection).to receive(:token_id).and_return(token)
    allow(connection).to receive(:expires_at).and_return(expires_at)
    allow(connection).to receive(:upload_url).and_return(upload_url)
  end

  describe "#execute" do

    let :upload do
      NightcrawlerSwift::Upload.new
    end

    it "executes upload command for each file of a directory" do
      dir = File.expand_path(File.join(File.dirname(__FILE__), "../../../fixtures/assets"))

      subject.instance_variable_set(:@upload, upload)
      expect(File).to receive(:open).with(File.join(dir, "css1.css"), "r").and_call_original
      expect(File).to receive(:open).with(File.join(dir, "ex1.txt"), "r").and_call_original
      expect(File).to receive(:open).with(File.join(dir, "ex2.txt"), "r").and_call_original
      expect(File).to receive(:open).with(File.join(dir, "ex3/ex4.txt"), "r").and_call_original
      expect(File).to receive(:open).with(File.join(dir, "js1.js"), "r").and_call_original

      expect(upload).to receive(:execute).with("css1.css", instance_of(File))
      expect(upload).to receive(:execute).with("ex1.txt", instance_of(File))
      expect(upload).to receive(:execute).with("ex2.txt", instance_of(File))
      expect(upload).to receive(:execute).with("ex3/ex4.txt", instance_of(File))
      expect(upload).to receive(:execute).with("js1.js", instance_of(File))

      subject.execute dir
    end

  end

end
