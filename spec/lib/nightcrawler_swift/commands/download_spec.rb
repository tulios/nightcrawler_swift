require 'spec_helper'

describe NightcrawlerSwift::Download do

  let(:connection) { NightcrawlerSwift::Connection.new }
  let(:token) { "token" }
  let(:expires_at) { (DateTime.now + 60).to_time }
  let(:public_url) { "server-url" }
  let(:bucket) { "rogue" }

  subject do
    NightcrawlerSwift::Download.new
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

    context "success" do
      let :response do
        double(:response, code: 200, body: "content")
      end

      before do
        allow(subject).to receive(:get).and_return(response)
      end

      it "gets using public url" do
        execute
        expect(subject).to have_received(:get).with("server-url/#{bucket}/file_path")
      end

      it "returns body" do
        expect(execute).to eql "content"
      end
    end

    context "when the file does not exist" do
      let :response do
        double(:response, code: 404)
      end

      before do
        allow(subject).to receive(:get).and_raise(RestClient::ResourceNotFound.new(response))
      end

      it "raises NightcrawlerSwift::Exceptions::NotFoundError" do
        expect { execute }.to raise_error NightcrawlerSwift::Exceptions::NotFoundError
      end
    end

    context "when the path was not informed" do
      it "raises NightcrawlerSwift::Exceptions::ValidationError" do
        expect { subject.execute nil }.to raise_error NightcrawlerSwift::Exceptions::ValidationError
        expect { subject.execute "" }.to raise_error NightcrawlerSwift::Exceptions::ValidationError
      end
    end

    context "when another error happens" do
      let :response do
        double(:response, code: 500)
      end

      before do
        allow(subject).to receive(:get).and_raise(RuntimeError.new(response))
      end

      it "raises NightcrawlerSwift::Exceptions::ConnectionError" do
        expect { execute }.to raise_error NightcrawlerSwift::Exceptions::ConnectionError
      end
    end
  end
end
