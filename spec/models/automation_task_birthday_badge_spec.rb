require 'spec_helper'

describe "Birthday Badge automation task" do

  it "Only allowed for Beavers and Cubs" do
    AutomationTaskBirthdayBadge::ALLOWED_SECTIONS.should == [:beavers, :cubs]
  end

  it "Requires correct permissions" do
    AutomationTaskBirthdayBadge.required_permissions.should == [ [:read, :member], [:write, :badge] ]
  end

  it "Has a human name" do
    AutomationTaskBirthdayBadge.human_name.should == "Birthday badges"
  end

  it "Has a human configuration" do
    AutomationTaskBirthdayBadge.new.human_configuration.should == "Between 2 days ago and 3 days from now."
  end


  describe "Perform task" do
    before :each do
      Timecop.freeze(DateTime.new(2016, 3, 8, 13, 30))
    end

    after :each do
      Timecop.return
    end
    
    it "Works" do
      section_id = 300
      user = FactoryGirl.build(:user_connected_to_osm)
      task = AutomationTaskBirthdayBadge.new(user: user, section_id: section_id)
      task.configuration = {badge_6: 6, badge_7: 7, badge_8: 8, badge_9: 9, badge_10: 10}

      Osm::Member.stub(:get_for_section).with(user.osm_api, section_id){ [
        Osm::Member.new(id: 401, first_name: 'A', last_name: 'Smith', grouping_id: -2, date_of_birth: Date.new(2000, 1, 2)),
        Osm::Member.new(id: 402, first_name: 'B', last_name: 'Smith', grouping_id: 2003, date_of_birth: nil),
        Osm::Member.new(id: 403, first_name: 'C', last_name: 'Smith', grouping_id: 2003, date_of_birth: (10.years.ago - 3.day)),
        Osm::Member.new(id: 404, first_name: 'D', last_name: 'Smith', grouping_id: 2003, date_of_birth: (10.years.ago - 2.day)),
        Osm::Member.new(id: 405, first_name: 'E', last_name: 'Smith', grouping_id: 2003, date_of_birth: 9.years.ago),
        Osm::Member.new(id: 406, first_name: 'F', last_name: 'Smith', grouping_id: 2003, date_of_birth: (8.years.ago + 3.day)),
        Osm::Member.new(id: 407, first_name: 'G', last_name: 'Smith', grouping_id: 2003, date_of_birth: (8.years.ago + 4.day)),
        Osm::Member.new(id: 408, first_name: 'H', last_name: 'Smith', grouping_id: 2003, date_of_birth: (7.years.ago - 1.day)),
        Osm::Member.new(id: 409, first_name: 'I', last_name: 'Smith', grouping_id: 2003, date_of_birth: (7.years.ago + 1.day)),
      ] }

      badge_6 = Osm::CoreBadge.new(id: 6, name: '6th Birthday badge')
      badge_7 = Osm::CoreBadge.new(id: 7, name: '7th Birthday badge')
      badge_8 = Osm::CoreBadge.new(id: 8, name: '8th Birthday badge')
      badge_9 = Osm::CoreBadge.new(id: 9, name: '9th Birthday badge')
      badge_10 = Osm::CoreBadge.new(id: 10, name: '10th Birthday badge')
      badge_data_7 = [
        Osm::Badge::Data.new(member_id: 408, awarded: 1, badge: badge_7),
        Osm::Badge::Data.new(member_id: 409, due: 1, badge: badge_7),
      ]
      badge_data_8 = [
        Osm::Badge::Data.new(member_id: 406, badge: badge_8),
        Osm::Badge::Data.new(member_id: 407, badge: badge_8),
      ]
      badge_data_9 = [
        Osm::Badge::Data.new(member_id: 405, badge: badge_9),
      ]
      badge_data_10 = [
        Osm::Badge::Data.new(member_id: 403, badge: badge_10),
        Osm::Badge::Data.new(member_id: 404, badge: badge_10),
      ]

      Osm::CoreBadge.stub(:get_badges_for_section).with(user.osm_api, section_id){ [badge_6, badge_7, badge_8, badge_9, badge_10] }
      badge_6.stub(:get_data_for_section).with(user.osm_api, section_id) { [] }
      badge_7.stub(:get_data_for_section).with(user.osm_api, section_id) { badge_data_7 }
      badge_8.stub(:get_data_for_section).with(user.osm_api, section_id) { badge_data_8 }
      badge_9.stub(:get_data_for_section).with(user.osm_api, section_id) { badge_data_9 }
      badge_10.stub(:get_data_for_section).with(user.osm_api, section_id) { badge_data_10 }
      badge_data_10[1].should_receive(:mark_due).with(user.osm_api, 1).exactly(1).times { true }
      badge_data_9[0].should_receive(:mark_due).with(user.osm_api, 1).exactly(1).times { true }
      badge_data_8[0].should_receive(:mark_due).with(user.osm_api, 1).exactly(1).times { true }

      ret_val = task.send(:perform_task)
      ret_val[:success].should == true
      ret_val[:errors].empty?.should == true
      ret_val[:log_lines].should == [
        "Checking members",
        [
          "A Smith skipped as they are a leader.",
          "B Smith skipped as they are missing a date of birth.",
          "C Smith skipped as their 11th bithday is outside the range.",
          "D Smith's 10th bithday is on 6 March",
          "E Smith's 9th bithday is on 8 March",
          "F Smith's 8th bithday is on 11 March",
          "G Smith skipped as their 8th bithday is outside the range.",
          "H Smith's 7th bithday is on 7 March",
          "I Smith's 7th bithday is on 9 March"
        ],
        "Found 5 birthdays.",
        [
          "10th Birthday badge has been marked due for D Smith.",
          "9th Birthday badge has been marked due for E Smith.",
          "8th Birthday badge has been marked due for F Smith.",
          "H Smith has already been awarded the \"7th Birthday badge\" badge.",
          "I Smith is already due the \"7th Birthday badge\" badge."
        ]
      ]
    end


    describe "Errors" do
      it "Couldn't get members" do
        user = FactoryGirl.build(:user_connected_to_osm)
        task = AutomationTaskBirthdayBadge.new(user: user, section_id: 300)
        Osm::Member.stub(:get_for_section){ [] }
        task.send(:perform_task).should == {
          :log_lines=>["Checking members", [], "Found no birthdays.", []],
          :errors=>[],
          :success=>true
        }
      end

      it "Couldn't mark badge as due" do
        section_id = 300
        user = FactoryGirl.build(:user_connected_to_osm)
        task = AutomationTaskBirthdayBadge.new(user: user, section_id: section_id)
        task.configuration = {badge_6: 6, badge_7: 7, badge_8: 8, badge_9: 9, badge_10: 10}
  
        Osm::Member.stub(:get_for_section).with(user.osm_api, section_id){ [
          Osm::Member.new(id: 405, first_name: 'E', last_name: 'Smith', grouping_id: 2003, date_of_birth: 9.years.ago),
        ] }
  
        badge_9 = Osm::CoreBadge.new(id: 9, name: '9th Birthday badge')
        badge_data_9 = Osm::Badge::Data.new(member_id: 405, badge: badge_9)

        Osm::CoreBadge.stub(:get_badges_for_section).with(user.osm_api, section_id){ [badge_9] }
        badge_9.stub(:get_data_for_section).with(user.osm_api, section_id) { [badge_data_9] }
        badge_data_9.should_receive(:mark_due).with(user.osm_api, 1).exactly(1).times { false }
  
        task.send(:perform_task).should == {
          success: false,
          errors: ["Error marking 9th Birthday badge as due for E Smith."],
          log_lines: ["Checking members", ["E Smith's 9th bithday is on 8 March"], "Found 1 birthday.", ["Error marking 9th Birthday badge as due for E Smith."]]
        }
      end
    end
  end


  describe "Correctly gets next birthday for member" do
    it "Day before birthday" do
      member = Osm::Member.new(date_of_birth: Date.new(2007, 10, 16))
      birthday = AutomationTaskBirthdayBadge.new.send(:next_birthday_for_member, member, Date.new(2016, 10, 15))
      birthday.should == Date.new(2016, 10, 16)
    end

    it "Day of birthday" do
      member = Osm::Member.new(date_of_birth: Date.new(2007, 10, 15))
      birthday = AutomationTaskBirthdayBadge.new.send(:next_birthday_for_member, member, Date.new(2016, 10, 15))
      birthday.should == Date.new(2016, 10, 15)
    end

    it "Day after birthday" do
      member = Osm::Member.new(date_of_birth: Date.new(2007, 10, 14))
      birthday = AutomationTaskBirthdayBadge.new.send(:next_birthday_for_member, member, Date.new(2016, 10, 15))
      birthday.should == Date.new(2017, 10, 14)
    end
  end

end
