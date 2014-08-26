require 'spec_helper'

describe NightcrawlerSwift::Command do

  subject do
    NightcrawlerSwift::Command.new
  end

  before do
    allow(NightcrawlerSwift).to receive(:connection).and_return(connection)
    allow(RestClient::Resource).to receive(:new).and_return(restclient)
  end

  let(:connection) { double(:connection, token_id: 'token-id') }

  describe "#put" do
    let(:restclient) { double(:restclient, put: response) }
    let(:response) { double(:response) }

    let :put do
      subject.send(:put, 'full-url', body: 'content', headers: {a: 1})
    end

    it "returns RestClient response" do
      expect(put).to eql(response)
    end

    it "sends body" do
      put
      expect(restclient).to have_received(:put).with('content', anything)
    end

    it "sends headers with token" do
      put
      expect(restclient).to have_received(:put).with(anything, {a: 1, "X-Storage-Token" => 'token-id'})
    end

    it "uses url to initialize RestClient" do
      put
      expect(RestClient::Resource).to have_received(:new).with('full-url', verify_ssl: false)
    end

  end

end
