require 'spec_helper'

describe NightcrawlerSwift::Metadata do

  let(:connection) { NightcrawlerSwift::Connection.new }
  let(:token) { "token" }
  let(:expires_at) { (DateTime.now + 60).to_time }
  let(:internal_url) { "server-url" }
  let(:bucket) { "rogue" }

  subject do
    NightcrawlerSwift::Metadata.new
  end

  before do
    allow(NightcrawlerSwift).to receive(:connection).and_return(connection)
    allow(connection).to receive(:token_id).and_return(token)
    allow(connection).to receive(:expires_at).and_return(expires_at)
    allow(connection).to receive(:internal_url).and_return(internal_url)
    NightcrawlerSwift.configure bucket: bucket
  end

  describe "#execute" do
    let(:file_path) { "file_path.css" }
    let(:execute) { subject.execute file_path }

    let :response do
      double(:response, code: 200, body: "", headers: {
        "content_type" => "text/css",
        "content_length" => "50013",
        "last_modified" => "Wed, 15 Oct 2014 13:38:56 GMT",
        "etag" => "e13839c545f32be23b942a41f3ea7724",
        "x_timestamp" => "1413380335.38118",
        "cache_control" => "public, max-age=604800",
        "x_trans_id" => "tx824d632ef9e54685a7563-005519f838"
      })
    end

    before do
      allow(subject).to receive(:head).and_return(response)
    end

    context "success" do
      it "gets using internal url" do
        execute
        expect(subject).to have_received(:head).with("server-url/#{bucket}/#{file_path}")
      end

      it "returns headers with symbolized keys" do
        output = execute
        expect(output).to eql response.headers.symbolize_keys
      end
    end

    context "when the path was not informed" do
      let(:file_path) { nil }

      it "removes the trailing slash" do
        execute
        expect(subject).to have_received(:head).with("server-url/#{bucket}")
      end
    end
  end
end
