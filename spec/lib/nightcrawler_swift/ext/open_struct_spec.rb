require 'spec_helper'

describe NightcrawlerSwift::Ext::OpenStruct do

  let :hash do
    {key1: "value", key2: true}
  end

  subject do
    OpenStruct.new hash
  end

  describe "#to_h" do
    it "returns a hash with the content" do
      expect(subject.to_h).to eql hash
    end

    describe "for a blank object" do
      subject do
        OpenStruct.new
      end

      it "returns an empty hash" do
        expect(subject.to_h).to eql({})
      end
    end
  end

end
