require 'spec_helper'

describe NightcrawlerSwift::Gateway do

  let :url do
    "http://some-url"
  end

  let :request_get do
    subject.request {|r| r.get}
  end

  let :opts do
    {}
  end

  subject do
    NightcrawlerSwift::Gateway.new url
  end

  before do
    NightcrawlerSwift.configure opts
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

    context "with ssl options" do
      context "but only 'ssl_client_cert'" do
        let :opts do
          {verify_ssl: true, ssl_client_cert: "somecert.pem"}
        end

        it "uses the configured option" do
          expect(RestClient::Resource).to receive(:new).with(
            url,
            timeout: NightcrawlerSwift.options.timeout,
            verify_ssl: NightcrawlerSwift.options.verify_ssl,
            ssl_client_cert: NightcrawlerSwift.options.ssl_client_cert
          )
          subject
        end
      end

      context "but only 'ssl_client_key'" do
        let :opts do
          {verify_ssl: true, ssl_client_key: "clientkey"}
        end

        it "uses the configured option" do
          expect(RestClient::Resource).to receive(:new).with(
            url,
            timeout: NightcrawlerSwift.options.timeout,
            verify_ssl: NightcrawlerSwift.options.verify_ssl,
            ssl_client_key: NightcrawlerSwift.options.ssl_client_key
          )
          subject
        end
      end

      context "but only 'ssl_ca_file'" do
        let :opts do
          {verify_ssl: true, ssl_ca_file: "Certificate Authority File"}
        end

        it "uses the configured option" do
          expect(RestClient::Resource).to receive(:new).with(
            url,
            timeout: NightcrawlerSwift.options.timeout,
            verify_ssl: NightcrawlerSwift.options.verify_ssl,
            ssl_ca_file: NightcrawlerSwift.options.ssl_ca_file
          )
          subject
        end
      end

      context "using all options" do
        let :opts do
          {
            verify_ssl: true,
            ssl_client_cert: "somecert.pem",
            ssl_client_key: "clientkey",
            ssl_ca_file: "Certificate Authority File"
          }
        end

        it "uses the configured options" do
          expect(RestClient::Resource).to receive(:new).with(
            url,
            timeout: NightcrawlerSwift.options.timeout,
            verify_ssl: NightcrawlerSwift.options.verify_ssl,
            ssl_client_cert: NightcrawlerSwift.options.ssl_client_cert,
            ssl_client_key: NightcrawlerSwift.options.ssl_client_key,
            ssl_ca_file: NightcrawlerSwift.options.ssl_ca_file
          )
          subject
        end
      end
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

      let :retries do
        3
      end

      context "with enough retries" do
        it "recovers from the failure" do
          expect(subject.resource).to receive(:get).once.and_raise(RuntimeError.new(response))
          expect(subject.resource).to receive(:get).once.and_return(true)
          expect(subject).to receive(:sleep).once.with(1)
          expect(subject).to_not receive(:sleep).with(2)
          expect { request_get }.to_not raise_error
          expect(subject.attempts).to eql(2) # original + one retry
        end
      end

      context "with all retries used" do
        before do
          NightcrawlerSwift.options.retries = retries
        end

        it "waits a time based on the attempt number and if no one results in a good request it raises the exception" do
          expect(subject.instance_variable_get(:@retries)).to eql retries
          expect(subject.resource).to receive(:get).exactly(4).times.and_raise(RuntimeError.new(response))
          expect(subject).to receive(:sleep).once.with(1)
          expect(subject).to receive(:sleep).once.with(2)
          expect(subject).to receive(:sleep).once.with(4)
          expect { request_get }.to raise_error NightcrawlerSwift::Exceptions::ConnectionError
          expect(subject.attempts).to eql(retries + 1)
        end

        context "and the time achieves max_retry_time" do
          it "waits the max_retry_time for every retry" do
            current_retry_time = NightcrawlerSwift.options.max_retry_time - 1
            subject.instance_variable_set(:@current_retry_time, current_retry_time)
            expect(subject.resource).to receive(:get).exactly(4).times.and_raise(RuntimeError.new(response))
            expect(subject).to receive(:sleep).once.with(current_retry_time)
            expect(subject).to receive(:sleep).twice.with(NightcrawlerSwift.options.max_retry_time)
            expect { request_get }.to raise_error NightcrawlerSwift::Exceptions::ConnectionError
            expect(subject.attempts).to eql(retries + 1)
          end
        end
      end

      context "with retries set to false" do
        before do
          NightcrawlerSwift.options.retries = false
          expect(subject).to_not receive(:sleep)
        end

        it "raises NightcrawlerSwift::Exceptions::ConnectionError" do
          expect(subject.resource).to receive(:get).once.and_raise(RuntimeError.new(response))
          expect { request_get }.to raise_error NightcrawlerSwift::Exceptions::ConnectionError
          expect(subject.attempts).to eql(1)
        end
      end
    end
  end

end
