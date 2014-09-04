require "spec_helper"
require "nightcrawler_swift/cli"

describe NightcrawlerSwift::CLI::Formatters::Basic do

  let :config_dir do
    File.expand_path(File.join(File.dirname(__FILE__), "../../../../fixtures"))
  end

  let :filepath do
    "testfile.txt"
  end

  let :runner do
    instance_double "Runner"
  end

  let :command do
    command_class.new
  end

  subject do
    NightcrawlerSwift::CLI::Formatters::Basic.new runner
  end

  describe "#command_list" do
    let :result do
      [{
        "hash"=>"c9df50d4a29542f8b6d426a50c72b3de",
        "last_modified"=>"2014-08-27T19:35:46.053560",
        "bytes"=>4994,
        "name"=>"assets/file.png",
        "content_type"=>"image/png"
      }]
    end

    let :command_class do
      NightcrawlerSwift::List
    end

    it "lists all files in the bucket/container configured" do
      expect(command_class).to receive(:new).and_return(command)
      expect(command).to receive(:execute).and_return(result)
      expect(runner).to receive(:log).with(result.first["name"])
      subject.command_list command_class
    end
  end

  describe "#command_download" do
    let :command_class do
      NightcrawlerSwift::Download
    end

    it "downloads the file" do
      expect(command_class).to receive(:new).and_return(command)
      expect(command).to receive(:execute).with(filepath).and_return("test-content")
      expect(runner).to receive(:log).with("test-content")
      expect(runner).to receive(:argv).and_return([filepath])
      subject.command_download command_class
    end
  end

  describe "#command_upload" do
    let :realpath do
      File.join config_dir, filepath
    end

    let :command_class do
      NightcrawlerSwift::Upload
    end

    before do
      File.open(realpath, "w") {|f| f.write("test") }
    end

    after do
      File.delete(realpath) if File.exist?(realpath)
    end

    it "uploads the file" do
      expect(command_class).to receive(:new).and_return(command)
      expect(command).to receive(:execute).with(filepath, instance_of(File)).and_return(true)
      expect(runner).to receive(:log).with("success")
      expect(runner).to receive(:argv).twice.and_return([realpath, filepath])
      subject.command_upload command_class
    end
  end

  describe "#command_delete" do
    let :command_class do
      NightcrawlerSwift::Delete
    end

    it "deletes the file" do
      expect(command_class).to receive(:new).and_return(command)
      expect(command).to receive(:execute).with(filepath).and_return(true)
      expect(runner).to receive(:log).with("success")
      expect(runner).to receive(:argv).and_return([filepath])
      subject.command_delete command_class
    end
  end

end
