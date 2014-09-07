require 'spec_helper'

describe NightcrawlerSwift::Command do

  subject do
    NightcrawlerSwift::Command.new
  end

  before do
    NightcrawlerSwift.configure
    allow(NightcrawlerSwift).to receive(:connection).and_return(connection)
    allow(connection).to receive(:token_id).and_return(token)
    allow(connection).to receive(:expires_at).and_return(expires_at)
    allow(RestClient::Resource).to receive(:new).and_return(restclient)
  end

  let(:connection) { NightcrawlerSwift::Connection.new }
  let(:restclient) { double(:restclient, put: response, get: response, delete: response) }
  let(:response) { double(:response) }
  let(:url) { "http://url-com" }
  let(:token) { "token" }
  let(:expires_at) { (DateTime.now + 60).to_time }

  shared_examples "command with configured gateway" do
    it "creates a new gateway with the url" do
      expect(NightcrawlerSwift::Gateway).to receive(:new).with(url).and_call_original
      execute_http
    end
  end

  describe "#connection" do
    context "when disconnected" do
      before do
        allow(NightcrawlerSwift.connection).to receive(:connected?).and_return(false)
      end

      it "connects and then return the connection" do
        expect(NightcrawlerSwift.connection).to receive(:connect!)
        expect(subject.connection).to eql(connection)
      end
    end

    context "when connected" do
      before do
        allow(NightcrawlerSwift.connection).to receive(:connected?).and_return(true)
      end

      it "returns the connection" do
        expect(NightcrawlerSwift.connection).to_not receive(:connect!)
        expect(subject.connection).to eql(connection)
      end
    end
  end

  describe "#options" do
    it "returns NightcrawlerSwift.options" do
      expect(subject.options).to eql(NightcrawlerSwift.options)
    end
  end

  describe "#get" do
    let :execute_http do
      subject.send :get, url, headers: {content_type: :json}
    end

    it_behaves_like "command with configured gateway"

    it "sends headers with token" do
      execute_http
      expect(restclient).to have_received(:get).with(content_type: :json, "X-Storage-Token" => token)
    end

    it "returns RestClient response" do
      expect(execute_http).to eql(response)
    end
  end

  describe "#delete" do
    let :execute_http do
      subject.send :delete, url, headers: {content_type: :json}
    end

    it_behaves_like "command with configured gateway"

    it "sends headers with token" do
      execute_http
      expect(restclient).to have_received(:delete).with(content_type: :json, "X-Storage-Token" => token)
    end

    it "returns RestClient response" do
      expect(execute_http).to eql(response)
    end
  end

  describe "#put" do
    let :execute_http do
      subject.send(:put, url, body: 'content', headers: {a: 1})
    end

    it_behaves_like "command with configured gateway"

    it "returns RestClient response" do
      expect(execute_http).to eql(response)
    end

    it "sends body" do
      execute_http
      expect(restclient).to have_received(:put).with('content', anything)
    end

    it "sends headers with token" do
      execute_http
      expect(restclient).to have_received(:put).with(anything, {a: 1, "X-Storage-Token" => token})
    end
  end

end
