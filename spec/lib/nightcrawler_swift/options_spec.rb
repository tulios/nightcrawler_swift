require 'spec_helper'

describe NightcrawlerSwift::Options do

  subject do
    NightcrawlerSwift::Options.new opts
  end

  let :opts do
    {}
  end

  describe "initialization" do
    context "verify_ssl" do
      it "defauts to false" do
        expect(subject.verify_ssl).to eql false
      end
    end

    context "retries" do
      it "defauts to 5" do
        expect(subject.retries).to eql 5
      end
    end

    context "max_retry_time" do
      it "defauts to 30" do
        expect(subject.max_retry_time).to eql 30
      end
    end

    context "password" do
      before do
        expect(ENV).to receive(:[]).with("NSWIFT_PASSWORD").and_return("123")
      end

      it "can be defined by the ENV variable 'NSWIFT_PASSWORD'" do
        expect(subject.password).to eql "123"
      end

      context "when configured" do
        let :opts do
          {password: "345"}
        end

        it "takes the ENV variable in precedence" do
          expect(subject.password).to eql "123"
        end
      end
    end

    context "and max_age isn't an integer" do
      let(:opts) { {max_age: "a string"} }

      it "raises NightcrawlerSwift::Exceptions::ConfigurationError" do
        expect { subject }.to raise_error(NightcrawlerSwift::Exceptions::ConfigurationError)
      end
    end

    context "when configured" do
      let :opts do
        {
          bucket: "rogue",
          password: "123",
          retries: 2
        }
      end

      it "creates with the given values" do
        expect(subject.bucket).to eql "rogue"
        expect(subject.password).to eql "123"
        expect(subject.retries).to eql 2
      end
    end
  end

end
