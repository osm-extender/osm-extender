require 'spec_helper'

describe "Chief Scout's Award automation task" do

  it "Only allowed for Beavers to Scouts" do
    AutomationTaskChiefScoutAward::ALLOWED_SECTIONS.should == [:beavers, :cubs, :scouts]
  end

  it "Requires correct permissions" do
    AutomationTaskChiefScoutAward.required_permissions.should == [ [:write, :badge], [:read, :member] ]
  end

  it "Has a human name" do
    AutomationTaskChiefScoutAward.human_name.should == "Chief Scout's award"
  end

  it "Has a human configuration" do
    AutomationTaskChiefScoutAward.new.human_configuration.should == 'Set badges column to "{COUNT-OF-BADGES} of {BADGES-NEEDED}" or "x{COUNT-OF-BADGES} of {BADGES-NEEDED}".'
  end



  describe "Perform task" do

    describe "Updates when achieved" do
      before :each do
        @badges = [Osm::ChallengeBadge.new(id: 1529), Osm::ChallengeBadge.new(id: 1587), Osm::ChallengeBadge.new(id: 1539)]
      end

      it "{COUNT-OF-BADGES} of {BADGES-NEEDED}" do
        section_id = 300
        user = FactoryGirl.build(:user_connected_to_osm)
        task = AutomationTaskChiefScoutAward.new(user: user, section_id: section_id)
        task.configuration = {achieved_action: 0}

        badge_data = Osm::Badge::Data.new(member_id: 201)
        badge_data.stub(:update){ true }

        Osm::Section.stub(:get){ Osm::Section.new(id: section_id, type: :beavers) }
        Osm::ChallengeBadge.stub(:get_badges_for_section){ @badges }
        @badges[0].stub(:get_data_for_section){ [badge_data] }
        Osm::Badge.stub(:get_summary_for_section){ [{
          member_id: 201, name: 'A Member',
          '401_0'=>:awarded, '401_0_date'=>Date.new(2010, 1, 1),
          '402_0'=>:awarded, '402_0_date'=>Date.new(2010, 1, 2),
          '403_0'=>:awarded, '403_0_date'=>Date.new(2010, 1, 3),
          '501_0'=>:awarded, '501_0_date'=>Date.new(2010, 1, 4),
        }] }
        Osm::Member.stub(:get_for_section){ [Osm::Member.new(id: 201, started_section: Date.new(2010, 1, 1))] }
        Osm::ActivityBadge.stub(:get_badges_for_section){ [Osm::ActivityBadge.new(identifier: '401_0'), Osm::ActivityBadge.new(identifier: '402_0'), Osm::ActivityBadge.new(identifier: '403_0')] }
        Osm::StagedBadge.stub(:get_badges_for_section){ [Osm::StagedBadge.new(identifier: '501_0')] }

        ret_val = task.send(:perform_task)
        badge_data.requirements.should == {114257=>"4 of 4"}
        ret_val.should == {:success=>true, :log_lines=>["A Member has achieved 4 of 4 activity/staged activity badges.", ["Updated data in OSM to \"4 of 4\"."]], :errors=>[]}
      end

      it "{COUNT-OF-BADGES}" do
        section_id = 300
        user = FactoryGirl.build(:user_connected_to_osm)
        task = AutomationTaskChiefScoutAward.new(user: user, section_id: section_id)
        task.configuration = {achieved_action: 1}

        badge_data = Osm::Badge::Data.new(member_id: 201)
        badge_data.stub(:update){ true }

        Osm::Section.stub(:get){ Osm::Section.new(id: section_id, type: :beavers) }
        Osm::ChallengeBadge.stub(:get_badges_for_section){ @badges }
        @badges[0].stub(:get_data_for_section){ [badge_data] }
        Osm::Badge.stub(:get_summary_for_section){ [{
          member_id: 201,
          '401_0'=>:awarded, '401_0_date'=>Date.new(2010, 1, 1),
          '402_0'=>:awarded, '402_0_date'=>Date.new(2010, 1, 2),
          '403_0'=>:awarded, '403_0_date'=>Date.new(2010, 1, 3),
          '501_0'=>:awarded, '501_0_date'=>Date.new(2010, 1, 4),
          '502_0'=>:awarded, '502_0_date'=>Date.new(2009, 12, 31),
        }] }
        Osm::Member.stub(:get_for_section){ [Osm::Member.new(id: 201, started_section: Date.new(2010, 1, 1))] }
        Osm::ActivityBadge.stub(:get_badges_for_section){ [Osm::ActivityBadge.new(identifier: '401_0'), Osm::ActivityBadge.new(identifier: '402_0'), Osm::ActivityBadge.new(identifier: '403_0')] }
        Osm::StagedBadge.stub(:get_badges_for_section){ [Osm::StagedBadge.new(identifier: '501_0'), Osm::StagedBadge.new(identifier: '502_0')] }

        ret_val = task.send(:perform_task)
        badge_data.requirements.should == {114257=>"4"}
        ret_val.should == {:success=>true, :log_lines=>[" has achieved 4 of 4 activity/staged activity badges.", ["Updated data in OSM to \"4\"."]], :errors=>[]}
      end

      it "[YES]" do
        section_id = 300
        user = FactoryGirl.build(:user_connected_to_osm)
        task = AutomationTaskChiefScoutAward.new(user: user, section_id: section_id)
        task.configuration = {achieved_action: 2}

        badge_data = Osm::Badge::Data.new(member_id: 201)
        badge_data.stub(:update){ true }

        Osm::Section.stub(:get){ Osm::Section.new(id: section_id, type: :beavers) }
        Osm::ChallengeBadge.stub(:get_badges_for_section){ @badges }
        @badges[0].stub(:get_data_for_section){ [badge_data] }
        Osm::Badge.stub(:get_summary_for_section){ [{
          member_id: 201,
          '401_0'=>:awarded, '401_0_date'=>Date.new(2010, 1, 1),
          '402_0'=>:awarded, '402_0_date'=>Date.new(2010, 1, 2),
          '403_0'=>:awarded, '403_0_date'=>Date.new(2010, 1, 3),
          '501_0'=>:awarded, '501_0_date'=>Date.new(2010, 1, 4),
          '502_0'=>:awarded, '502_0_date'=>Date.new(2010, 6, 1),
        }] }
        Osm::Member.stub(:get_for_section){ [Osm::Member.new(id: 201, started_section: Date.new(2010, 1, 1))] }
        Osm::ActivityBadge.stub(:get_badges_for_section){ [Osm::ActivityBadge.new(identifier: '401_0'), Osm::ActivityBadge.new(identifier: '402_0'), Osm::ActivityBadge.new(identifier: '403_0')] }
        Osm::StagedBadge.stub(:get_badges_for_section){ [Osm::StagedBadge.new(identifier: '501_0'), Osm::StagedBadge.new(identifier: '502_0')] }

        ret_val = task.send(:perform_task)
        badge_data.requirements.should == {114257=>"[YES]"}
        ret_val.should == {:success=>true, :log_lines=>[" has achieved 5 of 4 activity/staged activity badges.", ["Updated data in OSM to \"[YES]\"."]], :errors=>[]}
      end
    end


    describe "Updates when not achieved" do
      before :each do
        @badges = [Osm::ChallengeBadge.new(id: 1529), Osm::ChallengeBadge.new(id: 1587), Osm::ChallengeBadge.new(id: 1539)]
      end

      it "x{COUNT-OF-BADGES} of {BADGES-NEEDED}" do
        section_id = 300
        user = FactoryGirl.build(:user_connected_to_osm)
        task = AutomationTaskChiefScoutAward.new(user: user, section_id: section_id)
        task.configuration = {unachieved_action: 0}

        badge_data = Osm::Badge::Data.new(member_id: 201)
        badge_data.stub(:update){ true }

        Osm::Section.stub(:get){ Osm::Section.new(id: section_id, type: :beavers) }
        Osm::ChallengeBadge.stub(:get_badges_for_section){ @badges }
        @badges[0].stub(:get_data_for_section){ [badge_data] }
        Osm::Badge.stub(:get_summary_for_section){ [{
          member_id: 201, name: 'A Member',
          '401_0'=>:awarded, '401_0_date'=>Date.new(2010, 1, 1),
          '501_0'=>:awarded, '501_0_date'=>Date.new(2010, 1, 4),
        }] }
        Osm::Member.stub(:get_for_section){ [Osm::Member.new(id: 201, started_section: Date.new(2010, 1, 1))] }
        Osm::ActivityBadge.stub(:get_badges_for_section){ [Osm::ActivityBadge.new(identifier: '401_0'), Osm::ActivityBadge.new(identifier: '402_0'), Osm::ActivityBadge.new(identifier: '403_0')] }
        Osm::StagedBadge.stub(:get_badges_for_section){ [Osm::StagedBadge.new(identifier: '501_0')] }

        ret_val = task.send(:perform_task)
        badge_data.requirements.should == {114257=>"x2 of 4"}
        ret_val.should == {:success=>true, :log_lines=>["A Member has achieved 2 of 4 activity/staged activity badges.", ["Updated data in OSM to \"x2 of 4\"."]], :errors=>[]}
      end

      it "x{COUNT-OF-BADGES}" do
        section_id = 300
        user = FactoryGirl.build(:user_connected_to_osm)
        task = AutomationTaskChiefScoutAward.new(user: user, section_id: section_id)
        task.configuration = {unachieved_action: 1}

        badge_data = Osm::Badge::Data.new(member_id: 201)
        badge_data.stub(:update){ true }

        Osm::Section.stub(:get){ Osm::Section.new(id: section_id, type: :beavers) }
        Osm::ChallengeBadge.stub(:get_badges_for_section){ @badges }
        @badges[0].stub(:get_data_for_section){ [badge_data] }
        Osm::Badge.stub(:get_summary_for_section){ [{
          member_id: 201, name: 'A Member',
          '401_0'=>:awarded, '401_0_date'=>Date.new(2010, 1, 1),
          '501_0'=>:awarded, '501_0_date'=>Date.new(2010, 1, 4),
        }] }
        Osm::Member.stub(:get_for_section){ [Osm::Member.new(id: 201, started_section: Date.new(2010, 1, 1))] }
        Osm::ActivityBadge.stub(:get_badges_for_section){ [Osm::ActivityBadge.new(identifier: '401_0'), Osm::ActivityBadge.new(identifier: '402_0'), Osm::ActivityBadge.new(identifier: '403_0')] }
        Osm::StagedBadge.stub(:get_badges_for_section){ [Osm::StagedBadge.new(identifier: '501_0')] }

        ret_val = task.send(:perform_task)
        badge_data.requirements.should == {114257=>"x2"}
        ret_val.should == {:success=>true, :log_lines=>["A Member has achieved 2 of 4 activity/staged activity badges.", ["Updated data in OSM to \"x2\"."]], :errors=>[]}
      end

      it "Progress bar" do
        section_id = 300
        user = FactoryGirl.build(:user_connected_to_osm)
        task = AutomationTaskChiefScoutAward.new(user: user, section_id: section_id)
        task.configuration = {unachieved_action: 2}

        badge_data = Osm::Badge::Data.new(member_id: 201)
        badge_data.stub(:update){ true }

        Osm::Section.stub(:get){ Osm::Section.new(id: section_id, type: :beavers) }
        Osm::ChallengeBadge.stub(:get_badges_for_section){ @badges }
        @badges[0].stub(:get_data_for_section){ [badge_data] }
        Osm::Badge.stub(:get_summary_for_section){ [{
          member_id: 201, name: 'A Member',
          '401_0'=>:awarded, '401_0_date'=>Date.new(2010, 1, 1),
          '501_0'=>:awarded, '501_0_date'=>Date.new(2010, 1, 4),
        }] }
        Osm::Member.stub(:get_for_section){ [Osm::Member.new(id: 201, started_section: Date.new(2010, 1, 1))] }
        Osm::ActivityBadge.stub(:get_badges_for_section){ [Osm::ActivityBadge.new(identifier: '401_0'), Osm::ActivityBadge.new(identifier: '402_0'), Osm::ActivityBadge.new(identifier: '403_0')] }
        Osm::StagedBadge.stub(:get_badges_for_section){ [Osm::StagedBadge.new(identifier: '501_0')] }

        ret_val = task.send(:perform_task)
        badge_data.requirements.should == {114257=>"xx__"}
        ret_val.should == {:success=>true, :log_lines=>["A Member has achieved 2 of 4 activity/staged activity badges.", ["Updated data in OSM to \"xx__\"."]], :errors=>[]}
      end

      it "Progress bar (zero progress)" do
        section_id = 300
        user = FactoryGirl.build(:user_connected_to_osm)
        task = AutomationTaskChiefScoutAward.new(user: user, section_id: section_id)
        task.configuration = {unachieved_action: 2}

        badge_data = Osm::Badge::Data.new(member_id: 201, requirements: {114257=>'xNone'})
        badge_data.stub(:update){ true }

        Osm::Section.stub(:get){ Osm::Section.new(id: section_id, type: :beavers) }
        Osm::ChallengeBadge.stub(:get_badges_for_section){ @badges }
        @badges[0].stub(:get_data_for_section){ [badge_data] }
        Osm::Badge.stub(:get_summary_for_section){ [{
          member_id: 201, name: 'A Member',
        }] }
        Osm::Member.stub(:get_for_section){ [Osm::Member.new(id: 201, started_section: Date.new(2010, 1, 1))] }
        Osm::ActivityBadge.stub(:get_badges_for_section){ [Osm::ActivityBadge.new(identifier: '401_0'), Osm::ActivityBadge.new(identifier: '402_0'), Osm::ActivityBadge.new(identifier: '403_0')] }
        Osm::StagedBadge.stub(:get_badges_for_section){ [Osm::StagedBadge.new(identifier: '501_0')] }

        ret_val = task.send(:perform_task)
        badge_data.requirements.should == {114257=>""}
        ret_val.should == {:success=>true, :log_lines=>["A Member has achieved 0 of 4 activity/staged activity badges.", ["Updated data in OSM to \"\"."]], :errors=>[]}
      end

      it "Nothing" do
        section_id = 300
        user = FactoryGirl.build(:user_connected_to_osm)
        task = AutomationTaskChiefScoutAward.new(user: user, section_id: section_id)
        task.configuration = {unachieved_action: 3}

        badge_data = Osm::Badge::Data.new(member_id: 201, requirements: {114257=>'xNone'})
        badge_data.stub(:update){ true }

        Osm::Section.stub(:get){ Osm::Section.new(id: section_id, type: :beavers) }
        Osm::ChallengeBadge.stub(:get_badges_for_section){ @badges }
        @badges[0].stub(:get_data_for_section){ [badge_data] }
        Osm::Badge.stub(:get_summary_for_section){ [{
          member_id: 201, name: 'A Member',
          '401_0'=>:awarded, '401_0_date'=>Date.new(2010, 1, 1),
          '501_0'=>:awarded, '501_0_date'=>Date.new(2010, 1, 4),
        }] }
        Osm::Member.stub(:get_for_section){ [Osm::Member.new(id: 201, started_section: Date.new(2010, 1, 1))] }
        Osm::ActivityBadge.stub(:get_badges_for_section){ [Osm::ActivityBadge.new(identifier: '401_0'), Osm::ActivityBadge.new(identifier: '402_0'), Osm::ActivityBadge.new(identifier: '403_0')] }
        Osm::StagedBadge.stub(:get_badges_for_section){ [Osm::StagedBadge.new(identifier: '501_0')] }

        ret_val = task.send(:perform_task)
        badge_data.requirements.should == {114257=>""}
        ret_val.should == {:success=>true, :log_lines=>["A Member has achieved 2 of 4 activity/staged activity badges.", ["Updated data in OSM to \"\"."]], :errors=>[]}
      end
    end


    describe "Doesn't update OSM when data is the same" do
      it "When achieved" do
        section_id = 300
        user = FactoryGirl.build(:user_connected_to_osm)
        task = AutomationTaskChiefScoutAward.new(user: user, section_id: section_id)
        task.configuration = {achieved_action: 2}

        badge = Osm::ChallengeBadge.new(id: 1529)
        badge_data = Osm::Badge::Data.new(member_id: 201, requirements: {114257=>"[YES]"})

        Osm::Section.stub(:get){ Osm::Section.new(id: section_id, type: :beavers) }
        Osm::ChallengeBadge.stub(:get_badges_for_section){ [badge] }
        badge.stub(:get_data_for_section){ [badge_data] }
        Osm::Badge.stub(:get_summary_for_section){ [{
          member_id: 201,
          '401_0'=>:awarded, '401_0_date'=>Date.new(2010, 1, 1),
          '402_0'=>:awarded, '402_0_date'=>Date.new(2010, 1, 2),
          '403_0'=>:awarded, '403_0_date'=>Date.new(2010, 1, 3),
          '501_0'=>:awarded, '501_0_date'=>Date.new(2010, 1, 4),
          '502_0'=>:awarded, '502_0_date'=>Date.new(2010, 6, 1),
        }] }
        Osm::Member.stub(:get_for_section){ [Osm::Member.new(id: 201, started_section: Date.new(2010, 1, 1))] }
        Osm::ActivityBadge.stub(:get_badges_for_section){ [Osm::ActivityBadge.new(identifier: '401_0'), Osm::ActivityBadge.new(identifier: '402_0'), Osm::ActivityBadge.new(identifier: '403_0')] }
        Osm::StagedBadge.stub(:get_badges_for_section){ [Osm::StagedBadge.new(identifier: '501_0'), Osm::StagedBadge.new(identifier: '502_0')] }

        badge_data.should_not_receive(:update)
        task.send(:perform_task)
      end

      it "When not achieved" do
        section_id = 300
        user = FactoryGirl.build(:user_connected_to_osm)
        task = AutomationTaskChiefScoutAward.new(user: user, section_id: section_id)
        task.configuration = {unachieved_action: 0}

        badge = Osm::ChallengeBadge.new(id: 1529)
        badge_data = Osm::Badge::Data.new(member_id: 201, requirements: {114257=>"x1 of 4"})

        Osm::Section.stub(:get){ Osm::Section.new(id: section_id, type: :beavers) }
        Osm::ChallengeBadge.stub(:get_badges_for_section){ [badge] }
        badge.stub(:get_data_for_section){ [badge_data] }
        Osm::Badge.stub(:get_summary_for_section){ [{
          member_id: 201,
          '401_0'=>:awarded, '401_0_date'=>Date.new(2010, 1, 1),
        }] }
        Osm::Member.stub(:get_for_section){ [Osm::Member.new(id: 201, started_section: Date.new(2010, 1, 1))] }
        Osm::ActivityBadge.stub(:get_badges_for_section){ [Osm::ActivityBadge.new(identifier: '401_0'), Osm::ActivityBadge.new(identifier: '402_0'), Osm::ActivityBadge.new(identifier: '403_0')] }
        Osm::StagedBadge.stub(:get_badges_for_section){ [Osm::StagedBadge.new(identifier: '501_0'), Osm::StagedBadge.new(identifier: '502_0')] }

        badge_data.should_not_receive(:update)
        task.send(:perform_task)
      end
    end


    describe "Uses correct badge, requirement and badge total" do
      before :each do
        @badges = [Osm::ChallengeBadge.new(id: 1529), Osm::ChallengeBadge.new(id: 1587), Osm::ChallengeBadge.new(id: 1539)]
      end

      it "Beavers" do
        section_id = 300
        user = FactoryGirl.build(:user_connected_to_osm)
        task = AutomationTaskChiefScoutAward.new(user: user, section_id: section_id)
        task.configuration = {unachieved_action: 0}

        badge_data = Osm::Badge::Data.new(member_id: 201)
        badge_data.stub(:update){ true }

        Osm::Section.stub(:get){ Osm::Section.new(id: section_id, type: :beavers) }
        Osm::ChallengeBadge.stub(:get_badges_for_section){ @badges }
        Osm::Badge.stub(:get_summary_for_section){ [{
          member_id: 201,
          '401_0'=>:awarded, '401_0_date'=>Date.new(2010, 1, 1),
        }] }
        Osm::Member.stub(:get_for_section){ [Osm::Member.new(id: 201, started_section: Date.new(2010, 1, 1))] }
        Osm::ActivityBadge.stub(:get_badges_for_section){ [Osm::ActivityBadge.new(identifier: '401_0'), Osm::ActivityBadge.new(identifier: '402_0'), Osm::ActivityBadge.new(identifier: '403_0')] }
        Osm::StagedBadge.stub(:get_badges_for_section){ [Osm::StagedBadge.new(identifier: '501_0'), Osm::StagedBadge.new(identifier: '502_0')] }

        @badges[0].should_receive(:get_data_for_section){ [badge_data] }
        @badges[1].should_not_receive(:get_data_for_section)
        @badges[2].should_not_receive(:get_data_for_section)
        task.send(:perform_task)
        badge_data.requirements.should == {114257=>"x1 of 4"}
      end

      it "Cubs" do
        section_id = 300
        user = FactoryGirl.build(:user_connected_to_osm)
        task = AutomationTaskChiefScoutAward.new(user: user, section_id: section_id)
        task.configuration = {unachieved_action: 0}

        badge_data = Osm::Badge::Data.new(member_id: 201)
        badge_data.stub(:update){ true }

        Osm::Section.stub(:get){ Osm::Section.new(id: section_id, type: :cubs) }
        Osm::ChallengeBadge.stub(:get_badges_for_section){ @badges }
        Osm::Badge.stub(:get_summary_for_section){ [{
          member_id: 201,
          '401_0'=>:awarded, '401_0_date'=>Date.new(2010, 1, 1),
        }] }
        Osm::Member.stub(:get_for_section){ [Osm::Member.new(id: 201, started_section: Date.new(2010, 1, 1))] }
        Osm::ActivityBadge.stub(:get_badges_for_section){ [Osm::ActivityBadge.new(identifier: '401_0'), Osm::ActivityBadge.new(identifier: '402_0'), Osm::ActivityBadge.new(identifier: '403_0')] }
        Osm::StagedBadge.stub(:get_badges_for_section){ [Osm::StagedBadge.new(identifier: '501_0'), Osm::StagedBadge.new(identifier: '502_0')] }

        @badges[1].should_receive(:get_data_for_section){ [badge_data] }
        @badges[0].should_not_receive(:get_data_for_section)
        @badges[2].should_not_receive(:get_data_for_section)
        task.send(:perform_task)
        badge_data.requirements.should == {114603=>"x1 of 6"}
      end

      it "Scouts" do
        section_id = 300
        user = FactoryGirl.build(:user_connected_to_osm)
        task = AutomationTaskChiefScoutAward.new(user: user, section_id: section_id)
        task.configuration = {unachieved_action: 0}

        badge_data = Osm::Badge::Data.new(member_id: 201)
        badge_data.stub(:update){ true }

        Osm::Section.stub(:get){ Osm::Section.new(id: section_id, type: :scouts) }
        Osm::ChallengeBadge.stub(:get_badges_for_section){ @badges }
        Osm::Badge.stub(:get_summary_for_section){ [{
          member_id: 201,
          '401_0'=>:awarded, '401_0_date'=>Date.new(2010, 1, 1),
        }] }
        Osm::Member.stub(:get_for_section){ [Osm::Member.new(id: 201, started_section: Date.new(2010, 1, 1))] }
        Osm::ActivityBadge.stub(:get_badges_for_section){ [Osm::ActivityBadge.new(identifier: '401_0'), Osm::ActivityBadge.new(identifier: '402_0'), Osm::ActivityBadge.new(identifier: '403_0')] }
        Osm::StagedBadge.stub(:get_badges_for_section){ [Osm::StagedBadge.new(identifier: '501_0'), Osm::StagedBadge.new(identifier: '502_0')] }

        @badges[2].should_receive(:get_data_for_section){ [badge_data] }
        @badges[0].should_not_receive(:get_data_for_section)
        @badges[1].should_not_receive(:get_data_for_section)
        task.send(:perform_task)
        badge_data.requirements.should == {114339=>"x1 of 6"}
      end
    end


    describe "Errors" do
      it "Getting section" do
        section_id = 300
        user = FactoryGirl.build(:user_connected_to_osm)
        task = AutomationTaskChiefScoutAward.new(user: user, section_id: section_id)

        Osm::Section.stub(:get){ nil }
        task.send(:perform_task).should == {:success=>false, :errors=>["Could not retrieve section from OSM."]}
      end

      it "Getting badge" do
        section_id = 300
        user = FactoryGirl.build(:user_connected_to_osm)
        task = AutomationTaskChiefScoutAward.new(user: user, section_id: section_id)

        Osm::Section.stub(:get){ Osm::Section.new }
        Osm::ChallengeBadge.stub(:get_badges_for_section){ nil }
        task.send(:perform_task).should == {:success=>false, :errors=>["Could not retrieve Chief Scout's Award badge from OSM."]}
      end

      it "Updating badge data" do
        section_id = 300
        user = FactoryGirl.build(:user_connected_to_osm)
        task = AutomationTaskChiefScoutAward.new(user: user, section_id: section_id)
        task.configuration = {unachieved_action: 2}

        badge = Osm::ChallengeBadge.new(id: 1529)
        badge_data = Osm::Badge::Data.new(member_id: 201)
        badge_data.stub(:update){ false }

        Osm::Section.stub(:get){ Osm::Section.new(id: section_id, type: :beavers) }
        Osm::ChallengeBadge.stub(:get_badges_for_section){ [badge] }
        badge.stub(:get_data_for_section){ [badge_data] }
        Osm::Badge.stub(:get_summary_for_section){ [{
          member_id: 201, name: 'A Member',
          '401_0'=>:awarded, '401_0_date'=>Date.new(2010, 1, 1),
          '501_0'=>:awarded, '501_0_date'=>Date.new(2010, 1, 4),
        }] }
        Osm::Member.stub(:get_for_section){ [Osm::Member.new(id: 201, started_section: Date.new(2010, 1, 1))] }
        Osm::ActivityBadge.stub(:get_badges_for_section){ [Osm::ActivityBadge.new(identifier: '401_0'), Osm::ActivityBadge.new(identifier: '402_0'), Osm::ActivityBadge.new(identifier: '403_0')] }
        Osm::StagedBadge.stub(:get_badges_for_section){ [Osm::StagedBadge.new(identifier: '501_0')] }

        ret_val = task.send(:perform_task)
        ret_val.should == {:success=>false,  :errors=>["Couldn't update A Member's data to \"xx__\"."], :log_lines=>["A Member has achieved 2 of 4 activity/staged activity badges."]}
      end
    end

  end

end
