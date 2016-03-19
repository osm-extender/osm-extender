require 'spec_helper'

describe "Leadership automation task" do

  it "Only allowed for Beavers to Cubs" do
    AutomationTaskLeadership::ALLOWED_SECTIONS.should == [:cubs, :scouts]
  end

  it "Requires correct permissions" do
    AutomationTaskLeadership.required_permissions.should == [ [:read, :member], [:write, :badge] ]
  end

  it "Has a human name" do
    AutomationTaskLeadership.human_name.should == "Leadership badges"
  end

  it "Has a human configuration" do
    AutomationTaskFirstAid.new.human_configuration.should == 'Update first aid coloumn of outdoors challenge badge to "[YES]" preserving existing data.'
  end


  describe "Perform task" do

    describe "Cubs" do

      before :each do
        @section_id = 300
        @member_id = 400
        @user = FactoryGirl.build(:user_connected_to_osm)
        @task = AutomationTaskLeadership.new(user: @user, section_id: @section_id)

        Osm::Section.stub(:get){ Osm::Section.new(id: @Section_id, type: :cubs) }

        @core_badges = [
          Osm::CoreBadge.new(id: 186, identifier: '186_0', name: 'Seconder'),
          Osm::CoreBadge.new(id: 185, identifier: '185_0', name: 'Sixer'),
          Osm::CoreBadge.new(id: 187, identifier: '187_0', name: 'Senior Sixer'),
        ]
        Osm::CoreBadge.stub(:get_badges_for_section){ @core_badges }
        @core_badges[0].stub(:get_data_for_section){ [] }
        @core_badges[1].stub(:get_data_for_section){ [] }
        @core_badges[2].stub(:get_data_for_section){ [] }

        @member = Osm::Member.new(id: @member_id, grouping_leader: 0, first_name: 'A', last_name: 'Member')
        Osm::Member.stub(:get_for_section){ [@member] }
      end

      describe "Updates personal details" do

        it "Normal six member" do
          @member.should_not_receive(:update)
          ret_val = @task.send(:perform_task)
          ret_val.should == { success: true, log_lines: ["A Member is a \"Normal member\"."], errors: [] }
        end

        describe "Seconder" do
          it "Awarded" do
            @core_badges[0].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id, awarded: 1)] }
            @member.should_receive(:update){ true }

            ret_val = @task.send(:perform_task)
            ret_val.should == { success: true, log_lines: ["A Member is a \"Seconder\".", ["Updated personal details."]], errors: [] }
            @member.grouping_leader.should == 1
          end

          it "Due" do
            @core_badges[0].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id, due: 1)] }
            @member.should_receive(:update){ true }

            ret_val = @task.send(:perform_task)
            ret_val.should == { success: true, log_lines: ["A Member is a \"Seconder\".", ["Updated personal details."]], errors: [] }
            @member.grouping_leader.should == 1
          end
        end

        describe "Sixer" do
          it "Awarded" do
            @core_badges[1].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id, awarded: 1)] }
            @member.should_receive(:update){ true }

            ret_val = @task.send(:perform_task)
            ret_val.should == { success: true, log_lines: ["A Member is a \"Sixer\".", ["Updated personal details."]], errors: [] }
            @member.grouping_leader.should == 2
          end

          it "Due" do
            @core_badges[1].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id, due: 1)] }
            @member.should_receive(:update){ true }

            ret_val = @task.send(:perform_task)
            ret_val.should == { success: true, log_lines: ["A Member is a \"Sixer\".", ["Updated personal details."]], errors: [] }
            @member.grouping_leader.should == 2
          end
        end

        describe "Senior sixer" do
          it "Awarded" do
            @core_badges[2].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id, awarded: 1)] }
            @member.should_receive(:update){ true }

            ret_val = @task.send(:perform_task)
            ret_val.should == { success: true, log_lines: ["A Member is a \"Senior Sixer\".", ["Updated personal details."]], errors: [] }
            @member.grouping_leader.should == 3
          end

          it "Due" do
            @core_badges[2].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id, due: 1)] }
            @member.should_receive(:update){ true }

            ret_val = @task.send(:perform_task)
            ret_val.should == { success: true, log_lines: ["A Member is a \"Senior Sixer\".", ["Updated personal details."]], errors: [] }
            @member.grouping_leader.should == 3
          end
        end

        describe "Takes highest badge" do
          it "Senior sixer" do
            @core_badges[0].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id, awarded: 1)] }
            @core_badges[1].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id, awarded: 1)] }
            @core_badges[2].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id, awarded: 1)] }
            @member.should_receive(:update){ true }

            ret_val = @task.send(:perform_task)
            ret_val.should == { success: true, log_lines: ["A Member is a \"Senior Sixer\".", ["Updated personal details."]], errors: [] }
            @member.grouping_leader.should == 3
          end

          it "Sixer" do
            @core_badges[0].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id, awarded: 1)] }
            @core_badges[1].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id, awarded: 1)] }
            @member.should_receive(:update){ true }

            ret_val = @task.send(:perform_task)
            ret_val.should == { success: true, log_lines: ["A Member is a \"Sixer\".", ["Updated personal details."]], errors: [] }
            @member.grouping_leader.should == 2
          end
        end

        it "Errors" do
          @core_badges[0].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id, awarded: 1)] }
          @member.should_receive(:update){ false }

          ret_val = @task.send(:perform_task)
          ret_val.should == { success: false, log_lines: ["A Member is a \"Seconder\".", ["Couldn't update personal details."]], errors: ["Couldn't update personal details for A Member."] }
        end
      end # Updates personal details


      describe "Marks badge as due" do

        before :each do
          @member.should_not_receive(:update)
        end

        it "Normal six member" do
          ret_val = @task.send(:perform_task)
          ret_val.should == { success: true, log_lines: ["A Member is a \"Normal member\"."], errors: [] }
        end

        it "Seconder" do
          @member.grouping_leader = 1
          badge_data = Osm::Badge::Data.new(member_id: @member_id)
          badge_data.should_receive(:mark_due).with(@user.osm_api){ true }
          @core_badges[0].stub(:get_data_for_section){ [badge_data] }

          ret_val = @task.send(:perform_task)
          ret_val.should == { success: true, log_lines: ["A Member is a \"Seconder\".", ["Marked the \"Seconder\" badge as due."]], errors: [] }
        end

        it "Sixer" do
          @member.grouping_leader = 2
          badge_data = Osm::Badge::Data.new(member_id: @member_id)
          badge_data.should_receive(:mark_due).with(@user.osm_api){ true }
          @core_badges[1].stub(:get_data_for_section){ [badge_data] }

          ret_val = @task.send(:perform_task)
          ret_val.should == { success: true, log_lines: ["A Member is a \"Sixer\".", ["Marked the \"Sixer\" badge as due."]], errors: [] }
        end

        it "Senior sixer" do
          @member.grouping_leader = 3
          badge_data = Osm::Badge::Data.new(member_id: @member_id)
          badge_data.should_receive(:mark_due).with(@user.osm_api){ true }
          @core_badges[2].stub(:get_data_for_section){ [badge_data] }

          ret_val = @task.send(:perform_task)
          ret_val.should == { success: true, log_lines: ["A Member is a \"Senior Sixer\".", ["Marked the \"Senior Sixer\" badge as due."]], errors: [] }
        end

        it "Errors" do
          @member.grouping_leader = 1
          badge_data = Osm::Badge::Data.new(member_id: @member_id)
          badge_data.should_receive(:mark_due).with(@user.osm_api){ false }
          @core_badges[0].stub(:get_data_for_section){ [badge_data] }

          ret_val = @task.send(:perform_task)
          ret_val.should == { success: false, log_lines: ["A Member is a \"Seconder\".", ["Couldn't mark the \"Seconder\" badge as due."]], errors: ["Couldn't mark badge as due for \"Seconder\" & \"A Member\""] }
        end

      end # Updates badges

    end # Cubs


    describe "Scouts" do

      before :each do
        @section_id = 300
        @member_id = 400
        @user = FactoryGirl.build(:user_connected_to_osm)
        @task = AutomationTaskLeadership.new(user: @user, section_id: @section_id)

        Osm::Section.stub(:get){ Osm::Section.new(id: @Section_id, type: :scouts) }

        @core_badges = [
          Osm::CoreBadge.new(id: 91, identifier: '91_0', name: 'Assistant Patrol Leader'),
          Osm::CoreBadge.new(id: 90, identifier: '90_0', name: 'Patrol Leader'),
          Osm::CoreBadge.new(id: 92, identifier: '92_0', name: 'Senior Patrol Leader'),
        ]
        Osm::CoreBadge.stub(:get_badges_for_section){ @core_badges }
        @core_badges[0].stub(:get_data_for_section){ [] }
        @core_badges[1].stub(:get_data_for_section){ [] }
        @core_badges[2].stub(:get_data_for_section){ [] }

        @member = Osm::Member.new(id: @member_id, grouping_leader: 0, first_name: 'A', last_name: 'Member')
        Osm::Member.stub(:get_for_section){ [@member] }
      end

      describe "Updates personal details" do

        it "Normal patrol member" do
          @member.should_not_receive(:update)
          ret_val = @task.send(:perform_task)
          ret_val.should == { success: true, log_lines: ["A Member is a \"Normal member\"."], errors: [] }
        end

        describe "APL" do
          it "Awarded" do
            @core_badges[0].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id, awarded: 1)] }
            @member.should_receive(:update){ true }

            ret_val = @task.send(:perform_task)
            ret_val.should == { success: true, log_lines: ["A Member is a \"Assistant Patrol Leader\".", ["Updated personal details."]], errors: [] }
            @member.grouping_leader.should == 1
          end

          it "Due" do
            @core_badges[0].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id, due: 1)] }
            @member.should_receive(:update){ true }

            ret_val = @task.send(:perform_task)
            ret_val.should == { success: true, log_lines: ["A Member is a \"Assistant Patrol Leader\".", ["Updated personal details."]], errors: [] }
            @member.grouping_leader.should == 1
          end
        end

        describe "PL" do
          it "Awarded" do
            @core_badges[1].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id, awarded: 1)] }
            @member.should_receive(:update){ true }

            ret_val = @task.send(:perform_task)
            ret_val.should == { success: true, log_lines: ["A Member is a \"Patrol Leader\".", ["Updated personal details."]], errors: [] }
            @member.grouping_leader.should == 2
          end

          it "Due" do
            @core_badges[1].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id, due: 1)] }
            @member.should_receive(:update){ true }

            ret_val = @task.send(:perform_task)
            ret_val.should == { success: true, log_lines: ["A Member is a \"Patrol Leader\".", ["Updated personal details."]], errors: [] }
            @member.grouping_leader.should == 2
          end
        end

        describe "SPL" do
          it "Awarded" do
            @core_badges[2].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id, awarded: 1)] }
            @member.should_receive(:update){ true }

            ret_val = @task.send(:perform_task)
            ret_val.should == { success: true, log_lines: ["A Member is a \"Senior Patrol Leader\".", ["Updated personal details."]], errors: [] }
            @member.grouping_leader.should == 3
          end

          it "Due" do
            @core_badges[2].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id, due: 1)] }
            @member.should_receive(:update){ true }

            ret_val = @task.send(:perform_task)
            ret_val.should == { success: true, log_lines: ["A Member is a \"Senior Patrol Leader\".", ["Updated personal details."]], errors: [] }
            @member.grouping_leader.should == 3
          end
        end

        describe "Takes highest badge" do
          it "Senior patrol leader" do
            @core_badges[0].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id, awarded: 1)] }
            @core_badges[1].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id, awarded: 1)] }
            @core_badges[2].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id, awarded: 1)] }
            @member.should_receive(:update){ true }

            ret_val = @task.send(:perform_task)
            ret_val.should == { success: true, log_lines: ["A Member is a \"Senior Patrol Leader\".", ["Updated personal details."]], errors: [] }
            @member.grouping_leader.should == 3
          end

          it "Patrol leader" do
            @core_badges[0].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id, awarded: 1)] }
            @core_badges[1].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id, awarded: 1)] }
            @member.should_receive(:update){ true }

            ret_val = @task.send(:perform_task)
            ret_val.should == { success: true, log_lines: ["A Member is a \"Patrol Leader\".", ["Updated personal details."]], errors: [] }
            @member.grouping_leader.should == 2
          end
        end

        it "Errors" do
          @core_badges[0].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id, awarded: 1)] }
          @member.should_receive(:update){ false }

          ret_val = @task.send(:perform_task)
          ret_val.should == { success: false, log_lines: ["A Member is a \"Assistant Patrol Leader\".", ["Couldn't update personal details."]], errors: ["Couldn't update personal details for A Member."] }
        end

      end # Updates personal details

      describe "Marks badge as due" do

        before :each do
          @member.should_not_receive(:update)
        end

        it "Normal patrol member" do
          ret_val = @task.send(:perform_task)
          ret_val.should == { success: true, log_lines: ["A Member is a \"Normal member\"."], errors: [] }
        end

        it "APL" do
          @member.grouping_leader = 1
          badge_data = Osm::Badge::Data.new(member_id: @member_id)
          badge_data.should_receive(:mark_due).with(@user.osm_api){ true }
          @core_badges[0].stub(:get_data_for_section){ [badge_data] }

          ret_val = @task.send(:perform_task)
          ret_val.should == { success: true, log_lines: ["A Member is a \"Assistant Patrol Leader\".", ["Marked the \"Assistant Patrol Leader\" badge as due."]], errors: [] }
        end

        it "PL" do
          @member.grouping_leader = 2
          badge_data = Osm::Badge::Data.new(member_id: @member_id)
          badge_data.should_receive(:mark_due).with(@user.osm_api){ true }
          @core_badges[1].stub(:get_data_for_section){ [badge_data] }

          ret_val = @task.send(:perform_task)
          ret_val.should == { success: true, log_lines: ["A Member is a \"Patrol Leader\".", ["Marked the \"Patrol Leader\" badge as due."]], errors: [] }
        end

        it "SPL" do
          @member.grouping_leader = 3
          badge_data = Osm::Badge::Data.new(member_id: @member_id)
          badge_data.should_receive(:mark_due).with(@user.osm_api){ true }
          @core_badges[2].stub(:get_data_for_section){ [badge_data] }

          ret_val = @task.send(:perform_task)
          ret_val.should == { success: true, log_lines: ["A Member is a \"Senior Patrol Leader\".", ["Marked the \"Senior Patrol Leader\" badge as due."]], errors: [] }
        end

        it "Errors" do
          @member.grouping_leader = 1
          badge_data = Osm::Badge::Data.new(member_id: @member_id)
          badge_data.should_receive(:mark_due).with(@user.osm_api){false }
          @core_badges[0].stub(:get_data_for_section){ [badge_data] }

          ret_val = @task.send(:perform_task)
          ret_val.should == { success: false, log_lines: ["A Member is a \"Assistant Patrol Leader\".", ["Couldn't mark the \"Assistant Patrol Leader\" badge as due."]], errors: ["Couldn't mark badge as due for \"Assistant Patrol Leader\" & \"A Member\""] }
        end

      end # Updates badges

    end # Scouts


    describe "Errors" do

      before :each do
        @section_id = 300
        @section = Osm::Section.new(id: @Section_id, type: :cubs)

        @member_id = 400
        @member = Osm::Member.new(id: @member_id, grouping_leader: 0, first_name: 'A', last_name: 'Member')

        @user = FactoryGirl.build(:user_connected_to_osm)
        @task = AutomationTaskLeadership.new(user: @user, section_id: @section_id)

        @core_badges = [
          Osm::CoreBadge.new(id: 186, identifier: '186_0', name: 'Seconder'),
          Osm::CoreBadge.new(id: 185, identifier: '185_0', name: 'Sixer'),
          Osm::CoreBadge.new(id: 187, identifier: '187_0', name: 'Senior Sixer'),
        ]
      end

      it "Doesn't get a section" do
        Osm::Section.stub(:get){ nil }
        ret_val = @task.send(:perform_task)
        ret_val.should == { success: false, errors: ["Could not retrieve section from OSM."] }
      end

      describe "Doesn't get core badges" do
        it "Nil" do
          Osm::Section.stub(:get){ @section }
          Osm::CoreBadge.stub(:get_badges_for_section){ nil }
          ret_val = @task.send(:perform_task)
          ret_val.should == { success: false, errors: ["Could not retrieve core badges from OSM."] }
        end

        it "Empty array" do
          Osm::Section.stub(:get){ @section }
          Osm::CoreBadge.stub(:get_badges_for_section){ [] }
          ret_val = @task.send(:perform_task)
          ret_val.should == { success: false, errors: ["Could not retrieve core badges from OSM."] }
        end
      end

      describe "Doesn't get a badge" do

        describe "Seconder" do
          before :each do
            Osm::Section.stub(:get){ @section }
            Osm::Member.stub(:get_for_section){ [@member] }
            Osm::CoreBadge.stub(:get_badges_for_section){ [@core_badges[1], @core_badges[2]] }
            @core_badges[0].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id, awarded: 0)] }
            @core_badges[1].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id, awarded: 0)] }
            @core_badges[2].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id, awarded: 0)] }
          end

          it "Member is a seconder" do
            @member.grouping_leader = 1
            ret_val = @task.send(:perform_task)
            ret_val.should == { success: false, log_lines: ["A Member is a \"Seconder\".", ["Couldn't mark the badge as due - couldn't find it in OSM."]], errors: ["Couldn't find the Seconder badge amongst your badges."] }
          end

          it "Member is a sixer" do
            @member.grouping_leader = 2
            badge_data = Osm::Badge::Data.new(member_id: @member_id, awarded: 0)
            badge_data.stub(:mark_due){ true }
            @core_badges[1].stub(:get_data_for_section){ [badge_data] }
            ret_val = @task.send(:perform_task)
            ret_val.should == { success: true, log_lines: ["A Member is a \"Sixer\".", ["Marked the \"Sixer\" badge as due."]], errors: [] }
          end

          it "Member is a senior sixer" do
            @member.grouping_leader = 3
            badge_data = Osm::Badge::Data.new(member_id: @member_id, awarded: 0)
            badge_data.stub(:mark_due){ true }
            @core_badges[2].stub(:get_data_for_section){ [badge_data] }
            ret_val = @task.send(:perform_task)
            ret_val.should == { success: true, log_lines: ["A Member is a \"Senior Sixer\".", ["Marked the \"Senior Sixer\" badge as due."]], errors: [] }
          end
        end # Seconder

        describe "Sixer" do
          before :each do
            Osm::Section.stub(:get){ @section }
            Osm::Member.stub(:get_for_section){ [@member] }
            Osm::CoreBadge.stub(:get_badges_for_section){ [@core_badges[0], @core_badges[2]] }
            @core_badges[0].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id, awarded: 0)] }
            @core_badges[1].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id, awarded: 0)] }
            @core_badges[2].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id, awarded: 0)] }
          end

          it "Member is a seconder" do
            @member.grouping_leader = 1
            badge_data = Osm::Badge::Data.new(member_id: @member_id, awarded: 0)
            badge_data.stub(:mark_due){ true }
            @core_badges[0].stub(:get_data_for_section){ [badge_data] }
            ret_val = @task.send(:perform_task)
            ret_val.should == { success: true, log_lines: ["A Member is a \"Seconder\".", ["Marked the \"Seconder\" badge as due."]], errors: [] }
          end

          it "Member is a sixer" do
            @member.grouping_leader = 2
            ret_val = @task.send(:perform_task)
            ret_val.should == { success: false, log_lines: ["A Member is a \"Sixer\".", ["Couldn't mark the badge as due - couldn't find it in OSM."]], errors: ["Couldn't find the Sixer badge amongst your badges."] }
          end

          it "Member is a senior sixer" do
            @member.grouping_leader = 3
            badge_data = Osm::Badge::Data.new(member_id: @member_id, awarded: 0)
            badge_data.stub(:mark_due){ true }
            @core_badges[2].stub(:get_data_for_section){ [badge_data] }
            ret_val = @task.send(:perform_task)
            ret_val.should == { success: true, log_lines: ["A Member is a \"Senior Sixer\".", ["Marked the \"Senior Sixer\" badge as due."]], errors: [] }
          end
        end # Sixer

        describe "Senior Sixer" do
          before :each do
            Osm::Section.stub(:get){ @section }
            Osm::Member.stub(:get_for_section){ [@member] }
            Osm::CoreBadge.stub(:get_badges_for_section){ [@core_badges[0], @core_badges[1]] }
            @core_badges[0].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id, awarded: 0)] }
            @core_badges[1].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id, awarded: 0)] }
            @core_badges[2].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id, awarded: 0)] }
          end

          it "Member is a seconder" do
            @member.grouping_leader = 1
            badge_data = Osm::Badge::Data.new(member_id: @member_id, awarded: 0)
            badge_data.stub(:mark_due){ true }
            @core_badges[0].stub(:get_data_for_section){ [badge_data] }
            ret_val = @task.send(:perform_task)
            ret_val.should == { success: true, log_lines: ["A Member is a \"Seconder\".", ["Marked the \"Seconder\" badge as due."]], errors: [] }
          end

          it "Member is a sixer" do
            @member.grouping_leader = 2
            badge_data = Osm::Badge::Data.new(member_id: @member_id, awarded: 0)
            badge_data.stub(:mark_due){ true }
            @core_badges[1].stub(:get_data_for_section){ [badge_data] }
            ret_val = @task.send(:perform_task)
            ret_val.should == { success: true, log_lines: ["A Member is a \"Sixer\".", ["Marked the \"Sixer\" badge as due."]], errors: [] }
          end

          it "Member is a senior sixer" do
            @member.grouping_leader = 3
            ret_val = @task.send(:perform_task)
            ret_val.should == { success: false, log_lines: ["A Member is a \"Senior Sixer\".", ["Couldn't mark the badge as due - couldn't find it in OSM."]], errors: ["Couldn't find the Senior Sixer badge amongst your badges."] }
          end
        end # Senior Sixer

      end # Doesn't get a badge

      describe "Doesn't get badge data" do
        it "Empty array" do
          @member.grouping_leader = 1
          Osm::Section.stub(:get){ @section }
          Osm::CoreBadge.stub(:get_badges_for_section){ @core_badges }
          @core_badges[0].stub(:get_data_for_section){ [] }
          @core_badges[1].stub(:get_data_for_section){ [] }
          @core_badges[2].stub(:get_data_for_section){ [] }
          Osm::Member.stub(:get_for_section){ [@member] }

          ret_val = @task.send(:perform_task)
          ret_val.should == { success: false, log_lines: ["A Member is a \"Seconder\".", ["Couldn't mark the \"Seconder\" badge as due - couldn't find badge data for A Member."]], errors: ["Couldn't find badge data for \"Seconder\" & \"A Member\""] }
        end
      end

      describe "Doesn't get badge data for a member" do
        it "Seconder" do
          @member.grouping_leader = 1
          Osm::Section.stub(:get){ @section }
          Osm::CoreBadge.stub(:get_badges_for_section){ @core_badges }
          @core_badges[0].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id+1, awarded: 0)] }
          @core_badges[1].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id, awarded: 0)] }
          @core_badges[2].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id, awarded: 0)] }
          Osm::Member.stub(:get_for_section){ [@member] }

          ret_val = @task.send(:perform_task)
          ret_val.should == { success: false, log_lines: ["A Member is a \"Seconder\".", ["Couldn't mark the \"Seconder\" badge as due - couldn't find badge data for A Member."]], errors: ["Couldn't find badge data for \"Seconder\" & \"A Member\""] }
        end

        it "Sixer" do
          @member.grouping_leader = 2
          Osm::Section.stub(:get){ @section }
          Osm::CoreBadge.stub(:get_badges_for_section){ @core_badges }
          @core_badges[0].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id, awarded: 0)] }
          @core_badges[1].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id+1, awarded: 0)] }
          @core_badges[2].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id, awarded: 0)] }
          Osm::Member.stub(:get_for_section){ [@member] }

          ret_val = @task.send(:perform_task)
          ret_val.should == { success: false, log_lines: ["A Member is a \"Sixer\".", ["Couldn't mark the \"Sixer\" badge as due - couldn't find badge data for A Member."]], errors: ["Couldn't find badge data for \"Sixer\" & \"A Member\""] }
        end

        it "Senior sixer" do
          @member.grouping_leader = 3
          Osm::Section.stub(:get){ @section }
          Osm::CoreBadge.stub(:get_badges_for_section){ @core_badges }
          @core_badges[0].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id, awarded: 0)] }
          @core_badges[1].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id, awarded: 0)] }
          @core_badges[2].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id+1, awarded: 0)] }
          Osm::Member.stub(:get_for_section){ [@member] }

          ret_val = @task.send(:perform_task)
          ret_val.should == { success: false, log_lines: ["A Member is a \"Senior Sixer\".", ["Couldn't mark the \"Senior Sixer\" badge as due - couldn't find badge data for A Member."]], errors: ["Couldn't find badge data for \"Senior Sixer\" & \"A Member\""] }
        end
      end

      it "Doesn't get members" do
        Osm::Section.stub(:get){ @section }
        Osm::CoreBadge.stub(:get_badges_for_section){ @core_badges }
        @core_badges[0].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id, awarded: 0)] }
        @core_badges[1].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id, awarded: 0)] }
        @core_badges[2].stub(:get_data_for_section){ [Osm::Badge::Data.new(member_id: @member_id, awarded: 0)] }
        Osm::Member.stub(:get_for_section){ [] }

        ret_val = @task.send(:perform_task)
        ret_val.should == { success: true, log_lines: [], errors: [] }
      end

    end # Errors

  end # Perform task

end
