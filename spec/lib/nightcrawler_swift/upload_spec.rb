require 'spec_helper'

describe NightcrawlerSwift::Upload do

  subject do
    NightcrawlerSwift::Upload.new
  end

  describe "#execute" do
    let(:path) { "file_name" }
    let(:file) { double(:file, read: 'content') }
    let(:connection) do
      double(:connection, upload_url: 'server-url')
    end
    let(:response) do
      double(:response, code: 201)
    end

    before do
      allow(NightcrawlerSwift).to receive(:connection).and_return(connection)
      allow(subject).to receive(:put).and_return(response)
      subject.execute path, file
    end

    it "reads file content" do
      expect(file).to have_received(:read)
    end

    it "sends file content as body" do
      expect(subject).to have_received(:put).with(anything, body: 'content')
    end

    it "sends to upload url with given path" do
      expect(subject).to have_received(:put).with("server-url/file_name", anything)
    end
  end

end
