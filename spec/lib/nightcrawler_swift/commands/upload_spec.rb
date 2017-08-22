require 'digest'
require 'spec_helper'

describe NightcrawlerSwift::Upload do

  let(:connection) { NightcrawlerSwift::Connection.new }
  let(:token) { "token" }
  let(:expires_at) { (DateTime.now + 60).to_time }
  let(:upload_url) { "server-url" }

  subject do
    NightcrawlerSwift::Upload.new
  end

  before do
    NightcrawlerSwift.configure
    allow(NightcrawlerSwift).to receive(:connection).and_return(connection)
    allow(connection).to receive(:token_id).and_return(token)
    allow(connection).to receive(:expires_at).and_return(expires_at)
    allow(connection).to receive(:upload_url).and_return(upload_url)
  end

  describe "#execute" do
    let(:path) { "file_name" }
    let(:file) do
      dir = File.expand_path(File.join(File.dirname(__FILE__), "../../../fixtures/assets"))
      File.open(File.join(dir, "css1.css"))
    end

    let :response do
      double(:response, code: 201)
    end

    let :etag do
      Digest::MD5.hexdigest(file.read)
    end

    let :max_age do
      31536000
    end

    before do
      allow(subject).to receive(:put).and_return(response)
      allow(file).to receive(:read).and_return("content")
    end

    let :execute do
      subject.execute path, file
    end

    it "reads file content" do
      execute
      expect(file).to have_received(:read)
    end

    it "sends file content as body" do
      execute
      expect(subject).to have_received(:put).with(anything, hash_including(body: "content"))
    end

    it "sends file metadata as headers" do
      execute
      expect(subject).to have_received(:put).with(anything, hash_including(headers: { content_type: "text/css", etag: etag}))
    end

    it "sends to upload url with given path" do
      execute
      expect(subject).to have_received(:put).with("server-url/file_name", anything)
    end

    context "max_age" do
      let :default_headers do
        {content_type: "text/css", etag: etag}
      end

      it "sends default max_age into headers" do
        NightcrawlerSwift.configure max_age: max_age
        execute
        expect(subject).to have_received(:put).with(
          anything,
          hash_including(
            headers: hash_including(default_headers.merge(cache_control: "public, max-age=#{max_age}"))
          )
        )
      end

      it "allows custom max_age" do
        NightcrawlerSwift.configure
        subject.execute path, file, max_age: 1
        expect(subject).to have_received(:put).with(
          anything,
          hash_including(
            headers: hash_including(default_headers.merge(cache_control: "public, max-age=1"))
          )
        )
      end
    end

    context "custom_headers" do
      let :default_headers do
        {content_type: "text/css", etag: etag}
      end

      it "allows custom headers" do
        NightcrawlerSwift.configure
        subject.execute path, file, custom_headers: {custom_key: 'custom_value'}
        expect(subject).to have_received(:put).with(
          anything,
          hash_including(
            headers: hash_including(default_headers.merge(custom_key: 'custom_value'))
          )
        )
      end
    end

    context "expires" do
      let :default_headers do
        {content_type: "text/css", etag: etag}
      end
      let(:timestamp) { "Tue, 08 Dec 2015 17:03:31 GMT" }

      it "allows custom content_encoding" do
        time = Time.parse(timestamp)

        Timecop.freeze(time) do
          NightcrawlerSwift.configure
          subject.execute path, file, expires: time
          expect(subject).to have_received(:put).with(
            anything,
            hash_including(
              headers: hash_including(expires: timestamp)
            )
          )
        end
      end
    end

    context "content_encoding" do
      let :default_headers do
        {content_type: "text/css", etag: etag}
      end

      it "allows custom content_encoding" do
        NightcrawlerSwift.configure
        subject.execute path, file, content_encoding: 'gzip'
        expect(subject).to have_received(:put).with(
          anything,
          hash_including(
            headers: hash_including(content_encoding: "gzip")
          )
        )
      end
    end

    context "when response code is 200" do
      let(:response) { double(:response, code: 200) }
      it { expect(execute).to be true }
    end

    context "when response code is 201" do
      it { expect(execute).to be true }
    end

    context "when response code is different than 200 or 201" do
      let(:response) { double(:response, code: 500) }
      it { expect(execute).to be false }
    end

    context "when the path was not informed" do
      it "raises NightcrawlerSwift::Exceptions::ValidationError" do
        expect { subject.execute(nil, file) }.to raise_error NightcrawlerSwift::Exceptions::ValidationError
        expect { subject.execute("", file) }.to raise_error NightcrawlerSwift::Exceptions::ValidationError
      end
    end
  end

end
