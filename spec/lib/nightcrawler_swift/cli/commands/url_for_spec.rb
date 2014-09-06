require "spec_helper"
require "nightcrawler_swift/cli"

describe NightcrawlerSwift::CLI::UrlFor do

  let(:connection) { NightcrawlerSwift::Connection.new }
  let(:token) { "token" }
  let(:expires_at) { (DateTime.now + 60).to_time }
  let(:public_url) { "server-url" }
  let(:bucket) { "rogue" }

  subject do
    NightcrawlerSwift::CLI::UrlFor.new
  end

  before do
    allow(NightcrawlerSwift).to receive(:connection).and_return(connection)
    allow(connection).to receive(:token_id).and_return(token)
    allow(connection).to receive(:expires_at).and_return(expires_at)
    allow(connection).to receive(:public_url).and_return(public_url)
    NightcrawlerSwift.configure bucket: bucket
  end

  describe "#execute" do
    let :execute do
      subject.execute "file_path"
    end

    it "returns the public url of the given path" do
      expect(execute).to eql("server-url/#{bucket}/file_path")
    end
  end

end
