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

    context "success" do
      let :response do
        double(:response, code: 200)
      end

      before do
        allow(subject).to receive(:delete).and_return(response)
      end

      it "deletes using upload url" do
        execute
        expect(subject).to have_received(:delete).with("server-url/file_path", headers: {accept: :json})
      end

      it "returns true" do
        expect(execute).to eql true
      end
    end

    context "when the path was not informed" do
      it "raises NightcrawlerSwift::Exceptions::ValidationError" do
        expect { subject.execute nil }.to raise_error NightcrawlerSwift::Exceptions::ValidationError
        expect { subject.execute "" }.to raise_error NightcrawlerSwift::Exceptions::ValidationError
      end
    end
  end

end
