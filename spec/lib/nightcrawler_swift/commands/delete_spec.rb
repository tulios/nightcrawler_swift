require 'spec_helper'

describe NightcrawlerSwift::Delete do

  let(:connection) { NightcrawlerSwift::Connection.new }
  let(:token) { "token" }
  let(:expires_at) { (DateTime.now + 60).to_time }
  let(:upload_url) { "server-url" }

  subject do
    NightcrawlerSwift::Delete.new
  end

  before do
    allow(NightcrawlerSwift).to receive(:connection).and_return(connection)
    allow(connection).to receive(:token_id).and_return(token)
    allow(connection).to receive(:expires_at).and_return(expires_at)
    allow(connection).to receive(:upload_url).and_return(upload_url)
  end

  describe "#execute" do
    let :execute do
      subject.execute "file_path"
    end

    before do
      allow(subject).to receive(:delete).and_return(response)
    end

    context "success" do
      let :response do
        double(:response, code: 200)
      end

      it "deletes using upload url" do
        execute
        expect(subject).to have_received(:delete).with("server-url/file_path", headers: {accept: :json})
      end

      it "returns true" do
        expect(execute).to eql true
      end
    end

    context "when the file does not exist" do
      let :response do
        double(:response, code: 404)
      end

      before do
        allow(subject).to receive(:delete).and_raise(RestClient::ResourceNotFound.new(response))
      end

      it "raises NightcrawlerSwift::Exceptions::NotFoundError" do
        expect { execute }.to raise_error NightcrawlerSwift::Exceptions::NotFoundError
      end
    end

    context "when another error happens" do
      let :response do
        double(:response, code: 500)
      end

      before do
        allow(subject).to receive(:delete).and_raise(RuntimeError.new(response))
      end

      it "raises NightcrawlerSwift::Exceptions::ConnectionError" do
        expect { execute }.to raise_error NightcrawlerSwift::Exceptions::ConnectionError
      end
    end
  end

end
