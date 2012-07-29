# encoding: utf-8
require 'spec_helper'

describe "Grouping" do

  it "Create" do
    data = {
      'patrolid' => 1,
      'name' => 'Patrol Name',
      'active' => 1
    }
    patrol = Osm::Grouping.new(data)

    patrol.id.should == 1
    patrol.name.should == 'Patrol Name'
    patrol.active.should == true
  end

end