require "spec_helper"

describe UserMailer do
  describe "activation_needed" do
    let(:mail) { UserMailer.activation_needed }

    it "renders the headers" do
      mail.subject.should eq("Activation needed")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

  describe "activation_success" do
    let(:mail) { UserMailer.activation_success }

    it "renders the headers" do
      mail.subject.should eq("Activation success")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

  describe "reset_password" do
    let(:mail) { UserMailer.reset_password }

    it "renders the headers" do
      mail.subject.should eq("Reset password")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

end
