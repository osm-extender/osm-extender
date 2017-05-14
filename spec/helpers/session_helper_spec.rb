require 'spec_helper'

describe SessionHelper do

  describe "#show_paypal_donation?" do

    after :each do
      Timecop.return
    end

    it "Today is in a month an even multiple of 7 from start" do
      Timecop.travel(Time.local(2017, 9, 1))
      expect(helper.show_paypal_donation?).to be true

      Timecop.travel(Time.local(2018, 4, 15))
      expect(helper.show_paypal_donation?).to be true

      Timecop.travel(Time.local(2018, 11, 30))
      expect(helper.show_paypal_donation?).to be true
    end

    it "Today is NOT in a month an even multiple of 7 from start" do
      Timecop.travel(Time.local(2017, 8, 30))
      expect(helper.show_paypal_donation?).to be false

      Timecop.travel(Time.local(2017, 10, 1))
      expect(helper.show_paypal_donation?).to be false
    end

  end

end

