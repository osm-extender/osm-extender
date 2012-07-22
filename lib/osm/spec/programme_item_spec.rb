# encoding: utf-8
require 'spec_helper'
require 'date'

describe "Programme Item" do

  it "Create" do
    data = {
      'eveningid' => 1,
      'sectionid' => 2,
      'title' => 'Evening Name',
      'notesforparents' => 'Notes for parents',
      'games' => 'Games',
      'prenotes' => 'Before',
      'postnotes' => 'After',
      'leaders' => 'Leaders',
      'starttime' => '19:00',
      'endtime' => '21:00',
      'meetingdate' => '2000-01-02',
    }
    pi = Osm::ProgrammeItem.new(data, [])

    pi.evening_id.should == 1
    pi.section_id.should == 2
    pi.title.should == 'Evening Name'
    pi.notes_for_parents.should == 'Notes for parents'
    pi.games.should == 'Games'
    pi.pre_notes.should == 'Before'
    pi.post_notes.should == 'After'
    pi.leaders.should == 'Leaders'
    pi.start_time.should == '19:00'
    pi.end_time.should == '21:00'
    pi.meeting_date.should == Date.new(2000, 1, 2)
  end


  it "Raises exceptions when trying to set invalid times" do
    pi = Osm::ProgrammeItem.new({}, [])
    
    expect{ pi.start_time = 'abcde' }.to raise_error(ArgumentError)
    expect{ pi.start_time = '24:00' }.to raise_error(ArgumentError)
    expect{ pi.start_time = '10:61' }.to raise_error(ArgumentError)
    pi.start_time = '12:34'
    pi.start_time.should == '12:34'

    expect{ pi.end_time = 'abcde' }.to raise_error(ArgumentError)
    expect{ pi.end_time = '24:00' }.to raise_error(ArgumentError)
    expect{ pi.end_time = '10:61' }.to raise_error(ArgumentError)
    pi.end_time = '23:45'
    pi.end_time.should == '23:45'
  end


  it "Makes a list of activities to save for OSM's API" do
    pi = Osm::ProgrammeItem.new({}, [{
      'eveningid' => 1,
      'activityid' => 2,
      'title' => 'Activity Name',
      'notes' => 'Notes',
    }])
    pi.activities_for_saving.should == '[{"activityid":2,"notes":"Notes"}]'
  end

end