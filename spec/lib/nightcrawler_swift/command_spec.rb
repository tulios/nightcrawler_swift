require 'spec_helper'

describe NightcrawlerSwift::Command do

  subject do
    NightcrawlerSwift::Command.new
  end

  before do
    allow(NightcrawlerSwift).to receive(:connection).and_return(connection)
    allow(RestClient::Resource).to receive(:new).and_return(restclient)
  end

  let(:connection) { double(:connection, token_id: token) }
  let(:restclient) { double(:restclient, put: response, get: response) }
  let(:response) { double(:response) }

  let :url do
    "http://url.com"
  end

  let :token do
    "token"
  end

  describe "#get" do
    let :get do
      subject.send :get, url, headers: {content_type: :json}
    end

    it "uses url to initialize RestClient" do
      get
      expect(RestClient::Resource).to have_received(:new).with(url, verify_ssl: false)
    end

    it "sends headers with token" do
      get
      expect(restclient).to have_received(:get).with(content_type: :json, "X-Storage-Token" => token)
    end

    it "returns RestClient response" do
      expect(get).to eql(response)
    end
  end

  describe "#put" do
    let :put do
      subject.send(:put, url, body: 'content', headers: {a: 1})
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
      expect(restclient).to have_received(:put).with(anything, {a: 1, "X-Storage-Token" => token})
    end

    it "uses url to initialize RestClient" do
      put
      expect(RestClient::Resource).to have_received(:new).with(url, verify_ssl: false)
    end
  end

end
