require 'spec_helper'

describe NightcrawlerSwift::Hash do

  subject do
    {"key1" => "value1", "key2" => "value2"}
  end

  describe "#symbolize_keys" do
    it "creates a new hash with the symbolized keys" do
      result = subject.symbolize_keys
      expect(result).to include(key1: "value1", key2: "value2")
      expect(subject).to include("key1" => "value1", "key2" => "value2")
    end
  end

  describe "#symbolize_keys!" do
    it "destructively convert all keys to symbols" do
      result = subject.symbolize_keys!
      expect(result).to include(key1: "value1", key2: "value2")
      expect(subject).to include(key1: "value1", key2: "value2")
      expect(result).to eql subject
    end
  end

end
