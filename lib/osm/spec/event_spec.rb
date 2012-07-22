# encoding: utf-8
require 'spec_helper'
require 'date'

describe "Event" do

  it "Create" do
    data = {
      'eventid' => 1,
      'sectionid' => 2,
      'name' => 'Event name',
      'startdate' => '2001-01-02',
      'starttime' => '12:00:00',
      'enddate' => '2001-01-02',
      'endtime' => '13:00:00',
      'cost' => 'Free',
      'location' => 'Somewhere',
      'notes' => 'None'
    }
    event = Osm::Event.new(data)

    event.id.should == 1
    event.section_id.should == 2
    event.name.should == 'Event name'
    event.start.should == DateTime.new(2001, 1, 2, 12, 0, 0)
    event.end.should == DateTime.new(2001, 1, 2, 13, 0, 0)
    event.cost.should == 'Free'
    event.location.should == 'Somewhere'
    event.notes.should == 'None'
  end

end