# encoding: utf-8
require 'spec_helper'

describe "Activity" do

  it "Create" do
    data = {
        'details' => {
        'activityid' => '1',
        'version' => '0',
        'groupid' => '2',
        'userid' => '3',
        'title' => 'Activity Name',
        'description' => 'Description',
        'resources' => 'Resources',
        'instructions' => 'Instructions',
        'runningtime' => '15',
        'location' => 'indoors',
        'shared' => '0',
        'rating' => '4',
        'facebook' => ''
      },
      'editable' => true,
      'deletable' => false,
      'used' => 3,
      'versions' => [
        {
          'value' => '0',
          'userid' => '1',
          'firstname' => 'Alice',
          'label' => 'Current version - Alice',
          'selected' => 'selected'
        }
      ],
      'sections' => ['beavers', 'cubs'],
      'tags' => ['Tag 1', 'Tag2'],
      'files' => [],
      'badges' => []
    }
    activity = Osm::Activity.new(data)

    activity.id.should == 1
    activity.version.should == 0
    activity.group_id.should == 2
    activity.user_id.should == 3
    activity.title.should == 'Activity Name'
    activity.description.should == 'Description'
    activity.resources.should == 'Resources'
    activity.instructions.should == 'Instructions'
    activity.running_time.should == 15
    activity.location.should == :indoors
    activity.shared.should == 0
    activity.rating.should == 4
    activity.editable.should == true
    activity.deletable.should == false
    activity.used.should == 3
    activity.versions.should == [{:value => 0, :user_id => 1, :firstname => 'Alice', :label => 'Current version - Alice', :selected => true}]
    activity.sections.should == [:beavers, :cubs]
    activity.tags.should == ['Tag 1', 'Tag2']
    activity.files.should == []
    activity.badges.should == []
  end

end