require "spec_helper"

describe NightcrawlerSwift::List do

  subject do
    NightcrawlerSwift::List.new
  end

  describe "#execute" do
    let :connection do
      double :connection, upload_url: "server-url"
    end

    before do
      allow(NightcrawlerSwift).to receive(:connection).and_return(connection)
    end

    context "success" do
      let :json_response do
        [{"name" => "file"}]
      end

      let :response do
        double(:response, code: 200, body: json_response.to_json)
      end

      before do
        allow(subject).to receive(:get).and_return(response)
      end

      it "gets upload url" do
        subject.execute
        expect(subject).to have_received(:get).with(connection.upload_url, headers: {accept: :json})
      end

      it "returns the parsed json" do
        result = subject.execute
        expect(result).to eql json_response
      end
    end

    context "when the bucket does not exist" do
      let :response do
        double(:response, code: 400)
      end

      before do
        allow(subject).to receive(:get).and_raise(RestClient::ResourceNotFound.new(response))
      end

      it "raises NightcrawlerSwift::Exceptions::NotFoundError" do
        expect { subject.execute }.to raise_error NightcrawlerSwift::Exceptions::NotFoundError
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
        expect { subject.execute }.to raise_error NightcrawlerSwift::Exceptions::ConnectionError
      end
    end
  end

end
