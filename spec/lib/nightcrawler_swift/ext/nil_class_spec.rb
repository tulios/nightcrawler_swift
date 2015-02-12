require 'spec_helper'

describe NightcrawlerSwift::Ext::NilClass do

  subject do
    nil
  end

  describe "#to_h" do
    it "always returns an empty hash" do
      expect(subject.to_h).to eql({})
    end
  end

end
