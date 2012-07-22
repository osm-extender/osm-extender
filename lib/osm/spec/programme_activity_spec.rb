# encoding: utf-8
require 'spec_helper'

describe "Programme Activity" do

  it "Create" do
    data = {
      'eveningid' => 1,
      'activityid' => 2,
      'title' => 'Activity Name',
      'notes' => 'Notes',
    }
    pa = Osm::ProgrammeActivity.new(data)

    pa.evening_id.should == 1
    pa.activity_id.should == 2
    pa.title.should == 'Activity Name'
    pa.notes.should == 'Notes'
  end

end