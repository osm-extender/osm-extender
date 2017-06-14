describe "First Aid automation task" do

  it "Only allowed for Beavers to Cubs" do
    AutomationTaskFirstAid::ALLOWED_SECTIONS.should == [:beavers, :cubs]
  end

  it "Requires correct permissions" do
    AutomationTaskFirstAid.required_permissions.should == [ [:write, :badge] ]
  end

  it "Has a human name" do
    AutomationTaskFirstAid.human_name.should == "First aid in badges"
  end

  it "Has a human configuration" do
    AutomationTaskFirstAid.new.human_configuration.should == 'Update first aid coloumn of outdoors challenge badge to "[YES]" preserving existing data.'
  end


  describe "Perform task" do

    describe "Checks correct badge criteria are met" do
      before :each do
        @section_id = 300
        @section = Osm::Section.new(id: @section_id)
        @ea_badge = Osm::StagedBadge.new(id: 1643)
        @oc_badge_beavers = Osm::ChallengeBadge.new(id: 1515)
        @oc_badge_cubs = Osm::ChallengeBadge.new(id: 1581)
        @user = FactoryGirl.build(:user_connected_to_osm)
        @task = AutomationTaskFirstAid.new(user: @user, section_id: @section_id)

        Osm::Section.stub(:get).with(@user.osm_api, @section_id){ @section }
        Osm::StagedBadge.stub(:get_badges_for_section).with(@user.osm_api, @section){ [@ea_badge] }
        Osm::ChallengeBadge.stub(:get_badges_for_section).with(@user.osm_api, @section){ [@oc_badge_beavers, @oc_badge_cubs] }
      end

      describe "Beavers" do
        before :each do
          @section.type = :beavers
        end

        it "Met" do
          ea_data = Osm::Badge::Data.new(first_name: 'A', last_name: 'Member', section_id: @section_id, requirements: {115860 => 'Yes'})
          oc_data = Osm::Badge::Data.new(first_name: 'A', last_name: 'Member', section_id: @section_id,  requirements: {20989 => ''})
          oc_data.stub(:update){ true }
          @ea_badge.stub(:get_data_for_section).with(@user.osm_api, @section){ [ea_data] }
          @oc_badge_beavers.stub(:get_data_for_section).with(@user.osm_api, @section){ [oc_data] }

          @task.send(:perform_task).should == {:success=>true, :log_lines=>["A Member:", ["Completed 1 of 1 requirement.", "Updated challenge badge."]], :errors=>[]}
          oc_data.requirements[20989].should == '[YES]'
        end

        it "Unmet" do
          ea_data = Osm::Badge::Data.new(first_name: 'A', last_name: 'Member', section_id: @section_id, requirements: {115860 => 'xNo'})
          oc_data = Osm::Badge::Data.new(first_name: 'A', last_name: 'Member', section_id: @section_id,  requirements: {20989 => ''})
          oc_data.stub(:update){ true }
          @ea_badge.stub(:get_data_for_section).with(@user.osm_api, @section){ [ea_data] }
          @oc_badge_beavers.stub(:get_data_for_section).with(@user.osm_api, @section){ [oc_data] }

          @task.send(:perform_task).should == {:success=>true, :log_lines=>["A Member:", ["Completed 0 of 1 requirement."]], :errors=>[]}
          oc_data.requirements[20989].should == ''
        end

        (1..5).each do |level|
          it "EA badge level #{level} awarded" do
            ea_data = Osm::Badge::Data.new(first_name: 'A', last_name: 'Member', section_id: @section_id, awarded: level, awarded_date: Date.new(2016, 10, 13))
            oc_data = Osm::Badge::Data.new(first_name: 'A', last_name: 'Member', section_id: @section_id,  requirements: {20989 => ''})
            oc_data.stub(:update){ true }
            @ea_badge.stub(:get_data_for_section).with(@user.osm_api, @section){ [ea_data] }
            @oc_badge_beavers.stub(:get_data_for_section).with(@user.osm_api, @section){ [oc_data] }

            @task.send(:perform_task).should == {:success=>true, :log_lines=>["A Member:", ["Awarded level #{level} on 2016-10-13.", "Updated challenge badge."]], :errors=>[]}
            oc_data.requirements[20989].should == '[YES]'
          end
        end # each level
      end # Beavers

      describe "Cubs" do
        before :each do
          @section.type = :cubs
          @ea_data = Osm::Badge::Data.new(first_name: 'A', last_name: 'Member', section_id: @section_id, requirements: {115865=>'Yes', 115866=>'Yes', 20995=>'Yes', 115862=>'Yes', 115863=>'Yes'})
          @ea_data.stub('valid?'){ true }
          @oc_data = Osm::Badge::Data.new(first_name: 'A', last_name: 'Member', section_id: @section_id,  requirements: {100384 => ''})
          @oc_data.stub('valid?'){ true }
          @ea_badge.stub(:get_data_for_section).with(@user.osm_api, @section){ [@ea_data] }
          @oc_badge_cubs.stub(:get_data_for_section).with(@user.osm_api, @section){ [@oc_data] }
        end

        it "Met" do
          @oc_data.stub(:update){ true }

          @task.send(:perform_task).should == {:success=>true, :log_lines=>["A Member:", ["Completed 5 of 5 requirements.", "Updated challenge badge."]], :errors=>[]}
          @oc_data.requirements[100384].should == '[YES]'
        end

        describe "Unmet" do
          [115865, 115866, 20995, 115862, 115863].each do |r_id|
            it "Requirement #{r_id}" do
              @ea_data.requirements[r_id] = 'xNo'
              @task.send(:perform_task).should == {:success=>true, :log_lines=>["A Member:", ["Completed 4 of 5 requirements."]], :errors=>[]}
              @oc_data.requirements[100384].should == ''
            end
          end # each r_id
        end

        (2..5).each do |level|
          it "EA badge level #{level} awarded" do
            @ea_data.awarded = level
            @ea_data.awarded_date = Date.new(2016, 10, 13)
            @oc_data.stub(:update){ true }
            @ea_badge.stub(:get_data_for_section).with(@user.osm_api, @section){ [@ea_data] }
            @oc_badge_beavers.stub(:get_data_for_section).with(@user.osm_api, @section){ [@oc_data] }

            @task.send(:perform_task).should == {:success=>true, :log_lines=>["A Member:", ["Awarded level #{level} on 2016-10-13.", "Updated challenge badge."]], :errors=>[]}
            @oc_data.requirements[100384].should == '[YES]'
          end
        end # each level

        it "EA badge level 1 awarded" do
          @ea_data.awarded = 1
          @ea_data.awarded_date = Date.new(2016, 10, 13)
          @ea_data.requirements = {20989 => ''}
          @oc_data.stub(:update){ true }
          @ea_badge.stub(:get_data_for_section).with(@user.osm_api, @section){ [@ea_data] }
          @oc_badge_beavers.stub(:get_data_for_section).with(@user.osm_api, @section){ [@oc_data] }

          @task.send(:perform_task).should == {:success=>true, :log_lines=>["A Member:", ["Completed 0 of 5 requirements."]], :errors=>[]}
          @oc_data.requirements[100384].should == ''
        end

      end # Cubs
    end # Checks correct badge criteria are met


    describe "Only updates OSM if data changed" do
      before :each do
        @section_id = 400
        @section = Osm::Section.new(id: @section_id, type: :beavers)
        @ea_badge = Osm::StagedBadge.new(id: 1643)
        @oc_badge_beavers = Osm::ChallengeBadge.new(id: 1515)
        @oc_badge_cubs = Osm::ChallengeBadge.new(id: 1581)
        @user = FactoryGirl.build(:user_connected_to_osm)
        @task = AutomationTaskFirstAid.new(user: @user, section_id: @section_id)

        Osm::Section.stub(:get).with(@user.osm_api, @section_id){ @section }
        Osm::StagedBadge.stub(:get_badges_for_section).with(@user.osm_api, @section){ [@ea_badge] }
        Osm::ChallengeBadge.stub(:get_badges_for_section).with(@user.osm_api, @section){ [@oc_badge_beavers, @oc_badge_cubs] }

        @ea_data = Osm::Badge::Data.new(first_name: 'A', last_name: 'Member', section_id: @section_id)
        @oc_data = Osm::Badge::Data.new(first_name: 'A', last_name: 'Member', section_id: @section_id)
        @ea_badge.stub(:get_data_for_section).with(@user.osm_api, @section){ [@ea_data] }
        @oc_badge_beavers.stub(:get_data_for_section).with(@user.osm_api, @section){ [@oc_data] }
      end

      describe "When criteria are met" do
        it "Data changed" do
          @ea_data.requirements[115860] = 'Yes'
          @oc_data.requirements[20989] = ''
          @oc_data.should_receive(:update).with(@user.osm_api){ true }
          @task.send(:perform_task).should == {:success=>true, :log_lines=>["A Member:", ["Completed 1 of 1 requirement.", "Updated challenge badge."]], :errors=>[]}
          @oc_data.requirements[20989].should == '[YES]'
        end

        it "Data didn't change" do
          @ea_data.requirements[115860] = 'Yes'
          @oc_data.requirements[20989] = '[YES]'
          @oc_data.should_not_receive(:update)
          @task.send(:perform_task).should == {:success=>true, :log_lines=>["A Member:", ["Completed 1 of 1 requirement."]], :errors=>[]}
          @oc_data.requirements[20989].should == '[YES]'
        end
      end # criteria met

      describe "When criteria are met" do
        it "Data changed" do
          @ea_data.requirements[115860] = 'xNo'
          @oc_data.requirements[20989] = '[YES]'
          @oc_data.should_receive(:update).with(@user.osm_api){ true }
          @task.send(:perform_task).should == {:success=>true, :log_lines=>["A Member:", ["Completed 0 of 1 requirement.", "Updated challenge badge."]], :errors=>[]}
          @oc_data.requirements[20989].should == ''
        end

        it "Data didn't change" do
          @ea_data.requirements[115860] = 'xNo'
          @oc_data.requirements[20989] = ''
          @oc_data.should_not_receive(:update)
          @task.send(:perform_task).should == {:success=>true, :log_lines=>["A Member:", ["Completed 0 of 1 requirement."]], :errors=>[]}
          @oc_data.requirements[20989].should == ''
        end
      end # criteria not met
    end # Only updates OSM if data changed


    describe "Overwrite data option" do
      before :each do
        @section_id = 400
        @section = Osm::Section.new(id: @section_id, type: :beavers)
        @ea_badge = Osm::StagedBadge.new(id: 1643)
        @oc_badge_beavers = Osm::ChallengeBadge.new(id: 1515)
        @oc_badge_cubs = Osm::ChallengeBadge.new(id: 1581)
        @user = FactoryGirl.build(:user_connected_to_osm)
        @task = AutomationTaskFirstAid.new(user: @user, section_id: @section_id)

        Osm::Section.stub(:get).with(@user.osm_api, @section_id){ @section }
        Osm::StagedBadge.stub(:get_badges_for_section).with(@user.osm_api, @section){ [@ea_badge] }
        Osm::ChallengeBadge.stub(:get_badges_for_section).with(@user.osm_api, @section){ [@oc_badge_beavers, @oc_badge_cubs] }

        @ea_data = Osm::Badge::Data.new(first_name: 'A', last_name: 'Member', section_id: @section_id)
        @oc_data = Osm::Badge::Data.new(first_name: 'A', last_name: 'Member', section_id: @section_id)
        @ea_badge.stub(:get_data_for_section).with(@user.osm_api, @section){ [@ea_data] }
        @oc_badge_beavers.stub(:get_data_for_section).with(@user.osm_api, @section){ [@oc_data] }
      end

      describe "Disabled" do
        before :each do
          @task.configuration = {overwrite: false}
        end

        it "When data exists in OSM" do
          @ea_data.requirements[115860] = 'Yes'
          @oc_data.requirements[20989] = 'Something'
          @oc_data.should_not_receive(:update)
          @task.send(:perform_task).should == {:success=>true, :log_lines=>["A Member:", ["Completed 1 of 1 requirement.", "Didn't update challenge badge as data existed."]], :errors=>[]}
          @oc_data.requirements[20989].should == 'Something'
        end

        it "When blank data in OSM" do
          @ea_data.requirements[115860] = 'Yes'
          @oc_data.requirements[20989] = ''
          @oc_data.should_receive(:update){ true }
          @task.send(:perform_task).should == {:success=>true, :log_lines=>["A Member:", ["Completed 1 of 1 requirement.", "Updated challenge badge."]], :errors=>[]}
          @oc_data.requirements[20989].should == '[YES]'
        end
      end # Disabled

      describe "Enabled" do
        before :each do
          @task.configuration = {overwrite: true}
        end

        it "When data exists in OSM" do
          @ea_data.requirements[115860] = 'Yes'
          @oc_data.requirements[20989] = 'Something'
          @oc_data.should_receive(:update){ true }
          @task.send(:perform_task).should == {:success=>true, :log_lines=>["A Member:", ["Completed 1 of 1 requirement.", "Updated challenge badge."]], :errors=>[]}
          @oc_data.requirements[20989].should == '[YES]'
        end

        it "When blank data in OSM" do
          @ea_data.requirements[115860] = 'Yes'
          @oc_data.requirements[20989] = ''
          @oc_data.should_receive(:update){ true }
          @task.send(:perform_task).should == {:success=>true, :log_lines=>["A Member:", ["Completed 1 of 1 requirement.", "Updated challenge badge."]], :errors=>[]}
          @oc_data.requirements[20989].should == '[YES]'
        end
      end # Enabled
    end # Overwrite data option


    describe "Errors" do
      it "Getting section" do
        section_id = 300
        user = FactoryGirl.build(:user_connected_to_osm)
        task = AutomationTaskFirstAid.new(user: user, section_id: section_id)

        Osm::Section.stub(:get){ nil }
        task.send(:perform_task).should == {:success=>false, :errors=>["Could not retrieve section from OSM."]}
      end

      it "Getting emergency aid badge" do
        section_id = 300
        user = FactoryGirl.build(:user_connected_to_osm)
        task = AutomationTaskFirstAid.new(user: user, section_id: section_id)

        Osm::Section.stub(:get){ Osm::Section.new(id: section_id) }
        Osm::StagedBadge.stub(:get_badges_for_section){ [] }
        task.send(:perform_task).should == {:success=>false, :errors=>["Could not retrieve Emergency Aid badge from OSM."]}
      end

      it "Getting challenge badge" do
        section_id = 300
        user = FactoryGirl.build(:user_connected_to_osm)
        task = AutomationTaskFirstAid.new(user: user, section_id: section_id)

        Osm::Section.stub(:get){ Osm::Section.new(id: section_id) }
        Osm::StagedBadge.stub(:get_badges_for_section){ [Osm::StagedBadge.new(id: 1643)] }
        Osm::ChallengeBadge.stub(:get_badges_for_section){ [] }
        task.send(:perform_task).should == {:success=>false, :errors=>["Could not retrieve Outdoors Challenge badge from OSM."]}
      end

      describe "Updating badge data" do
        it "Returns false" do
          section_id = 300
          section = Osm::Section.new(id: section_id, type: :beavers)
          ea_badge = Osm::StagedBadge.new(id: 1643)
          oc_badge_beavers = Osm::ChallengeBadge.new(id: 1515)
          oc_badge_cubs = Osm::ChallengeBadge.new(id: 1581)
          user = FactoryGirl.build(:user_connected_to_osm)
          task = AutomationTaskFirstAid.new(user: user, section_id: section_id)
  
          Osm::Section.stub(:get).with(user.osm_api, section_id){ section }
          Osm::StagedBadge.stub(:get_badges_for_section).with(user.osm_api, section){ [ea_badge] }
          Osm::ChallengeBadge.stub(:get_badges_for_section).with(user.osm_api, section){ [oc_badge_beavers, oc_badge_cubs] }
  
          ea_data = Osm::Badge::Data.new(first_name: 'A', last_name: 'Member', section_id: @section_id, requirements: {115860 => 'Yes'})
          oc_data = Osm::Badge::Data.new(first_name: 'A', last_name: 'Member', section_id: @section_id,  requirements: {20989 => ''})
          oc_data.stub(:update){ false }
          ea_badge.stub(:get_data_for_section).with(user.osm_api, section){ [ea_data] }
          oc_badge_beavers.stub(:get_data_for_section).with(user.osm_api, section){ [oc_data] }
  
          task.send(:perform_task).should == {:success=>false, :log_lines=>["A Member:", ["Completed 1 of 1 requirement.", "Couldn't update challenge badge."]], :errors=>["Couldn't update challenge badge for A Member."]}
        end

        it "Raises Osm::Error" do
          section_id = 300
          section = Osm::Section.new(id: section_id, type: :beavers)
          ea_badge = Osm::StagedBadge.new(id: 1643)
          oc_badge_beavers = Osm::ChallengeBadge.new(id: 1515)
          oc_badge_cubs = Osm::ChallengeBadge.new(id: 1581)
          user = FactoryGirl.build(:user_connected_to_osm)
          task = AutomationTaskFirstAid.new(user: user, section_id: section_id)
  
          Osm::Section.stub(:get).with(user.osm_api, section_id){ section }
          Osm::StagedBadge.stub(:get_badges_for_section).with(user.osm_api, section){ [ea_badge] }
          Osm::ChallengeBadge.stub(:get_badges_for_section).with(user.osm_api, section){ [oc_badge_beavers, oc_badge_cubs] }
  
          ea_data = Osm::Badge::Data.new(first_name: 'A', last_name: 'Member', section_id: @section_id, requirements: {115860 => 'Yes'})
          oc_data = Osm::Badge::Data.new(first_name: 'A', last_name: 'Member', section_id: @section_id,  requirements: {20989 => ''})
          oc_data.stub(:update){ raise Osm::Error, "A message" }
          ea_badge.stub(:get_data_for_section).with(user.osm_api, section){ [ea_data] }
          oc_badge_beavers.stub(:get_data_for_section).with(user.osm_api, section){ [oc_data] }
  
          task.send(:perform_task).should == {:success=>false, :log_lines=>["A Member:", ["Completed 1 of 1 requirement.", "Couldn't update challenge badge. OSM said \"A message\"."]], :errors=>["Couldn't update challenge badge for A Member. OSM said \"A message\"."]}
        end
      end

    end # Errors

  end

end
