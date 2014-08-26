require 'spec_helper'

describe NightcrawlerSwift::Download do

  subject do
    NightcrawlerSwift::Download.new
  end

  describe "#execute" do
    let :connection do
      double :connection, public_url: "server-url"
    end

    let :execute do
      subject.execute "file_path"
    end

    before do
      allow(NightcrawlerSwift).to receive(:connection).and_return(connection)
      allow(subject).to receive(:get).and_return(response)
    end

    context "success" do
      let :response do
        double(:response, code: 200, body: "content")
      end

      it "gets using upload url" do
        execute
        expect(subject).to have_received(:get).with("server-url/file_path")
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
