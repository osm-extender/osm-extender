# encoding: utf-8
require 'spec_helper'


describe "API Access" do

  it "Create" do
    data = {
      'apiid' => '1',
      'name' => 'Name',
      'permissions' => {'permission' => '100'},
    }
    api_access = Osm::ApiAccess.new(data)

    api_access.id.should == 1
    api_access.name.should == 'Name'
    api_access.permissions.should == {:permission => 100}
  end


  it "Allows interegation of the permissions hash" do
    api_access = Osm::ApiAccess.new({
      'apiid' => '1',
      'name' => 'Name',
      'permissions' => {
        'read_only' => 10,
        'read_write' => 20,
      },
    })

    api_access.can_read?(:read_only).should == true
    api_access.can_read?(:read_write).should == true

    api_access.can_write?(:read_only).should == false
    api_access.can_write?(:read_write).should == true

    api_access.can_read?(:non_existant).should == false
    api_access.can_write?(:non_existant).should == false
  end


  it "Tells us if it's the our api" do
    Osm::Api.stub(:api_id) { '1' }

    apis = {
      :ours => Osm::ApiAccess.new({'apiid' => '1', 'name' => 'Name', 'permissions' => {}}),
      :not_ours => Osm::ApiAccess.new({'apiid' => '2', 'name' => 'Name', 'permissions' => {}}),
    }

    apis[:ours].our_api?.should == true
    apis[:not_ours].our_api?.should == false
  end

end
