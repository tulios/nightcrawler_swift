require "spec_helper"

describe NightcrawlerSwift::List do

  let(:connection) { NightcrawlerSwift::Connection.new }
  let(:token) { "token" }
  let(:expires_at) { (DateTime.now + 60).to_time }
  let(:upload_url) { "server-url" }

  subject do
    NightcrawlerSwift::List.new
  end

  before do
    allow(NightcrawlerSwift).to receive(:connection).and_return(connection)
    allow(connection).to receive(:token_id).and_return(token)
    allow(connection).to receive(:expires_at).and_return(expires_at)
    allow(connection).to receive(:upload_url).and_return(upload_url)
  end

  describe "#execute" do
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

end
