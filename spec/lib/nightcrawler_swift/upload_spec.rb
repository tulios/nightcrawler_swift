require 'digest'
require 'spec_helper'

describe NightcrawlerSwift::Upload do

  subject do
    NightcrawlerSwift::Upload.new
  end

  describe "#execute" do
    let(:path) { "file_name" }
    let(:file) do
      dir = File.expand_path(File.join(File.dirname(__FILE__), "../../fixtures/assets"))
      File.open(File.join(dir, "css1.css"))
    end

    let :connection do
      double :connection, upload_url: "server-url", opts: OpenStruct.new {}
    end

    let :response do
      double(:response, code: 201)
    end

    let :etag do
      '"%s"' % Digest::MD5.new.update(file.read).hexdigest
    end

    let :max_age do
      31536000
    end

    before do
      allow(NightcrawlerSwift).to receive(:connection).and_return(connection)
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

    it "sends max_age into headers" do
      connection.opts.max_age = max_age
      execute
      expect(subject).to have_received(:put).with(anything, hash_including(headers: { content_type: "text/css", etag: etag, cache_control: "max-age=#{max_age}" }))
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
  end

end
