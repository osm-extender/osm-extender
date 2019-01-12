describe "Automation Task" do
  it "Has a valid factory" do
    task = FactoryBot.build(:automation_task)
    task.class.stub(:human_name){ 'Human name for automation task' }
    task.stub(:only_one_of_each_type){ true }
    task.stub(:set_section_name){ true }
    task.should be_valid
  end

  it "Is invalid without user" do
    task = FactoryBot.build(:automation_task, user: nil)
    task.class.stub(:human_name){ 'Human name for automation task' }
    task.stub(:only_one_of_each_type){ true }
    task.should_not be_valid
  end

  it "Is invalid without section_id" do
    user = FactoryBot.build(:user)
    task = FactoryBot.build(:automation_task, user: user, section_id: nil)
    task.class.stub(:human_name){ 'Human name for automation task' }
    task.stub(:only_one_of_each_type){ true }
    task.stub(:set_section_name){ true }
    task.should_not be_valid
  end

  it "Finds unused tasks" do
    class AutomationTaskTestItemBeavers < AutomationTask
      ALLOWED_SECTIONS = [:beavers]
    end
    AutomationTaskTestItemBeavers.stub('has_permissions?'){ true }

    class AutomationTaskTestItemBeaversCubs < AutomationTask
      ALLOWED_SECTIONS = [:beavers, :cubs]
    end
    AutomationTaskTestItemBeaversCubs.stub('has_permissions?'){ false }

    class AutomationTaskTestItemCubs < AutomationTask
      ALLOWED_SECTIONS = [:cubs]
    end
 
    Module.stub(:constants) { [:AutomationTaskTestItemBeavers, :AutomationTaskTestItemBeaversCubs, :AutomationTaskTestItemCubs] }
    AutomationTask.stub(:where){ [] }

    ret_val = AutomationTask.unused_items(FactoryBot.build(:user), Osm::Section.new(id: 456, type: :beavers))
    ret_val.should == [
      { type: AutomationTaskTestItemBeavers, has_permissions: true },
      { type: AutomationTaskTestItemBeaversCubs, has_permissions: false }
    ]
  end


  describe "Overridden methods" do
    it "human_name" do
      expect { AutomationTask.new.human_name }.to raise_exception(RuntimeError, "The self.human_name method must be overridden")
    end

    it "self.human_name" do
      expect { AutomationTask.human_name }.to raise_exception(RuntimeError, "The self.human_name method must be overridden")
    end

    it "self.required_permissions" do
      expect { AutomationTask.required_permissions }.to raise_exception(RuntimeError, "The self.required_permissions method must be overridden")
    end

    it "self.default_configuration" do
      AutomationTask.default_configuration.should == {}
    end

    it "self.configuration_labels" do
      AutomationTask.configuration_labels.should == {}
    end

    it "self.configuration_types" do
      AutomationTask.configuration_types.should == {}
    end

    it "human_configuration" do
      AutomationTask.new.human_configuration.should == "There are no settings for this item."
    end

    it "perform_task" do
      expect { AutomationTask.new.send(:perform_task) }.to raise_exception(RuntimeError, "The perform_task method must be overridden")
    end

    describe "With a default configuration" do

      before :each do
        Object.send(:remove_const, :AutomationTaskTestItem)
        class AutomationTaskTestItem < AutomationTask
          def self.default_configuration
            {a: 'a'}
          end
        end
      end

      it "self.configuration_labels" do
        expect { AutomationTaskTestItem.configuration_labels }.to raise_exception(RuntimeError, "The self.configuration_labels method must be overridden")
      end

      it "self.configuration_types" do
        expect { AutomationTaskTestItem.configuration_types }.to raise_exception(RuntimeError, "The self.configuration_types method must be overridden")
      end

      it "human_configuration" do
        expect { AutomationTaskTestItem.new.human_configuration }.to raise_exception(RuntimeError, "The human_configuration method must be overridden")
      end
    end
  end


  describe "Do Task method" do
    it "User not connected to OSM" do
      user = FactoryBot.build(:user)
      task = FactoryBot.build(:automation_task, user: user)
      task.do_task.should == {success: false, errors: ["#{user.name} hasn't connected their account to OSM yet."]}
    end

    it "Doesn't have OSM permissions" do
      user = FactoryBot.build(:user_connected_to_osm)
      task = FactoryBot.build(:automation_task, user: user)
      task.class.stub('has_permissions?'){ false }
      task.do_task.should == {success: false, errors: ["#{user.name} doesn't have the correct OSM permissions."]}
    end

    it "Calls perform_task method" do
      user = FactoryBot.build(:user_connected_to_osm)
      task = FactoryBot.build(:automation_task, user: user)
      task.class.stub('has_permissions?'){ true }
      task.should_receive(:perform_task).with(user).exactly(1).times { {success: true} }
      task.do_task.should == {success: true}
    end

    it "With different user" do
      user = FactoryBot.build(:user_connected_to_osm)
      task = FactoryBot.build(:automation_task, user: user)
      task.class.stub('has_permissions?'){ true }
      different_user = FactoryBot.build(:user_connected_to_osm)
      task.should_receive(:perform_task).with(different_user).exactly(1).times { {success: true} }
      task.do_task(different_user).should == {success: true}
    end
  end


  describe "Updates configuration" do
      class AutomationTaskTestItem < AutomationTask
        def self.default_configuration;     {a: 100}         end
        def self.configuration_types;       {a: :integer}    end
      end

    it "For integer" do
      class AutomationTaskTestItem < AutomationTask
        def self.default_configuration;     {a: 100}         end
        def self.configuration_types;       {a: :integer}    end
      end
      task = AutomationTaskTestItem.new
      task.configuration.should == {a: 100}
      task.configuration = {a: 200}
      task.configuration.should == {a: 200}
    end

    it "For positive integer" do
      class AutomationTaskTestItem < AutomationTask
        def self.default_configuration;     {a: 100}         end
        def self.configuration_types;       {a: :positive_integer}    end
      end
      task = AutomationTaskTestItem.new
      task.configuration.should == {a: 100}
      task.configuration = {a: 200}
      task.configuration.should == {a: 200}
    end

    it "For boolean" do
      class AutomationTaskTestItem < AutomationTask
        def self.default_configuration;     {a: false}         end
        def self.configuration_types;       {a: :boolean}    end
      end
      task = AutomationTaskTestItem.new
      task.configuration.should == {a: false}
      task.configuration = {a: true}
      task.configuration.should == {a: true}
    end

    it "For String" do
      class AutomationTaskTestItem < AutomationTask
        def self.default_configuration;     {a: '100'}         end
        def self.configuration_types;       {a: :string}    end
      end
      task = AutomationTaskTestItem.new
      task.configuration.should == {a: '100'}
      task.configuration = {a: '200'}
      task.configuration.should == {a: '200'}
    end

    it "For symbol" do
      class AutomationTaskTestItem < AutomationTask
        def self.default_configuration;     {a: :a}         end
        def self.configuration_types;       {a: :symbol}    end
      end
      task = AutomationTaskTestItem.new
      task.configuration.should == {a: :a}
      task.configuration = {a: :b}
      task.configuration.should == {a: :b}
    end

    describe "Does conversions" do
      it "To integer" do
        class AutomationTaskTestItem < AutomationTask
          def self.default_configuration;     {a: nil}         end
          def self.configuration_types;       {a: :integer}    end
        end
        value = "123"
        value.should_receive(:to_i).exactly(1).times { 123 }
        task = AutomationTaskTestItem.new
        task.configuration = {a: value}
        task.configuration.should == {a: 123}
      end

      it "To positive integer" do
        class AutomationTaskTestItem < AutomationTask
          def self.default_configuration;     {a: nil}         end
          def self.configuration_types;       {a: :positive_integer}    end
        end
        task = AutomationTaskTestItem.new

        task.configuration = {a: "123"}
        task.configuration.should == {a: 123}

        task.configuration = {a: "-123"}
        task.configuration.should == {a: 123}
      end

      it "To boolean" do
        class AutomationTaskTestItem < AutomationTask
          def self.default_configuration;     {a: nil}         end
          def self.configuration_types;       {a: :boolean}    end
        end

        task = AutomationTaskTestItem.new
        task.configuration = {a: '1'}
        task.configuration[:a].should == true

        task = AutomationTaskTestItem.new
        task.configuration = {a: '0'}
        task.configuration[:a].should == false

        task = AutomationTaskTestItem.new
        task.configuration = {a: 'a'}
        task.configuration[:a].should == true

        task = AutomationTaskTestItem.new
        task.configuration = {a: 0}
        task.configuration[:a].should == false

        task = AutomationTaskTestItem.new
        task.configuration = {a: 1}
        task.configuration[:a].should == true

        task = AutomationTaskTestItem.new
        task.configuration = {a: false}
        task.configuration[:a].should == false

        task = AutomationTaskTestItem.new
        task.configuration = {a: true}
        task.configuration[:a].should == true
      end

      it "To string" do
        class AutomationTaskTestItem < AutomationTask
          def self.default_configuration;     {a: nil}         end
          def self.configuration_types;       {a: :string}    end
        end
        value = 'a'
        value.should_receive(:to_s).exactly(1).times { "a" }
        task = AutomationTaskTestItem.new
        task.configuration = {a: value}
        task.configuration.should == {a: "a"}
      end

      it "To symbol" do
        class AutomationTaskTestItem < AutomationTask
          def self.default_configuration;     {a: nil}         end
          def self.configuration_types;       {a: :symbol}    end
        end
        value = "a"
        value.should_receive(:to_sym).exactly(1).times { :a }
        task = AutomationTaskTestItem.new
        task.configuration = {a: value}
        task.configuration.should == {a: :a}
      end
    end

    it "Only accepts keys which are present in the default configuration" do
      class AutomationTaskTestItem < AutomationTask
        def self.default_configuration;     {a: 1}         end
      end
      task = AutomationTaskTestItem.new
      task.configuration = {a: 2, b: 3}
      task.configuration.should == {a: 2}
    end
  end

end
