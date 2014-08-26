require 'spec_helper'

describe NightcrawlerSwift::Upload do

  subject do
    NightcrawlerSwift::Upload.new
  end

  describe "#execute" do
    let(:path) { "file_name" }
    let(:file) { double(:file, read: "content") }

    let :connection do
      double :connection, upload_url: "server-url"
    end

    let :response do
      double(:response, code: 201)
    end

    before do
      allow(NightcrawlerSwift).to receive(:connection).and_return(connection)
      allow(subject).to receive(:put).and_return(response)
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
      expect(subject).to have_received(:put).with(anything, body: "content")
    end

    it "sends to upload url with given path" do
      execute
      expect(subject).to have_received(:put).with("server-url/file_name", anything)
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
