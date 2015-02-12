require 'spec_helper'

describe NightcrawlerSwift::Ext::Hash do

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

  describe "#compact" do
    subject do
      {key1: nil, key2: "value2", key3: nil}
    end

    it "creates a new hash without the nil items" do
      result = subject.compact
      expect(result).to_not include(:key1, :key3)
      expect(result).to include(:key2)

      expect(subject).to include(:key1, :key2, :key3)
    end
  end

  describe "#compact!" do
    subject do
      {key1: nil, key2: "value2", key3: nil}
    end

    it "destructively remove the items with the nil value" do
      result = subject.compact!
      expect(result).to_not include(:key1, :key3)
      expect(result).to include(:key2)
      expect(subject).to_not include(:key1, :key3)
      expect(subject).to include(:key2)

      expect(result).to eql subject
    end
  end

end
