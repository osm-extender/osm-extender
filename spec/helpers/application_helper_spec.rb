describe ApplicationHelper do

  describe "#seconds_to_time" do

    it "A second" do
      Timecop.travel(Time.local(2018, 11, 30))
      expect(helper.seconds_to_time(1.second.to_i)).to eq '1 second'
    end

    it "Under a minute" do
      Timecop.travel(Time.local(2018, 11, 30))
      expect(helper.seconds_to_time(45.seconds.to_i)).to eq '45 seconds'
    end

    it "A minute" do
      Timecop.travel(Time.local(2018, 11, 30))
      expect(helper.seconds_to_time(1.minute.to_i)).to eq '1 minute'
    end

    it "1 minute and 30 seconds" do
      Timecop.travel(Time.local(2018, 11, 30))
      expect(helper.seconds_to_time(90.seconds.to_i)).to eq '1 minute and 30 seconds'
    end

    it "2 minutes" do
      Timecop.travel(Time.local(2018, 11, 30))
      expect(helper.seconds_to_time(2.minutes.to_i)).to eq '2 minutes'
    end

    it "An hour" do
      Timecop.travel(Time.local(2018, 11, 30))
      expect(helper.seconds_to_time(1.hour.to_i)).to eq '1 hour'
    end

    it "1 hour and 30 minutes" do
      Timecop.travel(Time.local(2018, 11, 30))
      expect(helper.seconds_to_time(90.minutes.to_i)).to eq '1 hour and 30 minutes'
    end

    it "2 hours" do
      Timecop.travel(Time.local(2018, 11, 30))
      expect(helper.seconds_to_time(2.hours.to_i)).to eq '2 hours'
    end

    it "A day" do
      Timecop.travel(Time.local(2018, 11, 30))
      expect(helper.seconds_to_time(1.day.to_i)).to eq '1 day'
    end

    it "1 day and 12 hours" do
      Timecop.travel(Time.local(2018, 11, 30))
      expect(helper.seconds_to_time(36.hours.to_i)).to eq '1 day and 12 hours'
    end

    it "2 days" do
      Timecop.travel(Time.local(2018, 11, 30))
      expect(helper.seconds_to_time(2.days.to_i)).to eq '2 days'
    end

    it "A week" do
      Timecop.travel(Time.local(2018, 11, 30))
      expect(helper.seconds_to_time(1.week.to_i)).to eq '1 week'
    end

    it "1 week and 2 days" do
      Timecop.travel(Time.local(2018, 11, 30))
      expect(helper.seconds_to_time(9.days.to_i)).to eq '1 week and 2 days'
    end

    it "2 weeks" do
      Timecop.travel(Time.local(2018, 11, 30))
      expect(helper.seconds_to_time(2.weeks.to_i)).to eq '2 weeks'
    end

    it "1 week, 2 days, 3 hours and 1 second" do
      Timecop.travel(Time.local(2018, 11, 30))
      expect(helper.seconds_to_time((1.week + 2.days + 3.hours + 1.second).to_i)).to eq '1 week, 2 days, 3 hours and 1 second'
    end


  end

end

