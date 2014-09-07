require 'spec_helper'

describe NightcrawlerSwift::Gateway do

  let :url do
    "http://some-url"
  end

  let :request_get do
    subject.request {|r| r.get}
  end

  subject do
    NightcrawlerSwift::Gateway.new url
  end

  before do
    NightcrawlerSwift.configure
  end

  describe "initialization" do
    it "creates the resource with the url and the options: verify_ssl and timeout" do
      expect(RestClient::Resource).to receive(:new).with(
        url,
        verify_ssl: NightcrawlerSwift.options.verify_ssl,
        timeout: NightcrawlerSwift.options.timeout
      )
      subject
    end
  end

  describe "#request" do
    context "with a successful request" do
      it "calls the received block" do
        expect(subject).to receive(:request).and_yield(subject.resource)
        subject.request {|resource| }
      end
    end

    context "when it is not authorized" do
      let(:response) { double(:response, code: 401) }

      before do
        allow(subject.resource).to receive(:get).and_raise(RestClient::Unauthorized.new(response))
      end

      it "raises NightcrawlerSwift::Exceptions::UnauthorizedError" do
        expect { request_get }.to raise_error NightcrawlerSwift::Exceptions::UnauthorizedError
      end
    end

    context "when the resource does not exist" do
      let(:response) { double(:response, code: 404) }

      before do
        allow(subject.resource).to receive(:get).and_raise(RestClient::ResourceNotFound.new(response))
      end

      it "raises NightcrawlerSwift::Exceptions::NotFoundError" do
        expect { request_get }.to raise_error NightcrawlerSwift::Exceptions::NotFoundError
      end
    end

    context "when rescue RestClient::UnprocessableEntity" do
      let(:response) { double(:response, code: 422) }

      before do
        allow(subject.resource).to receive(:get).and_raise(RestClient::UnprocessableEntity.new(response))
      end

      it "wraps into NightcrawlerSwift::Exceptions::ValidationError" do
        expect { request_get }.to raise_error NightcrawlerSwift::Exceptions::ValidationError
      end
    end

    context "when another error happens" do
      let :response do
        double(:response, code: 500)
      end

      before do
        allow(subject.resource).to receive(:get).and_raise(RuntimeError.new(response))
      end

      it "raises NightcrawlerSwift::Exceptions::ConnectionError" do
        expect { request_get }.to raise_error NightcrawlerSwift::Exceptions::ConnectionError
      end
    end
  end

end
