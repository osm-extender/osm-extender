# encoding: utf-8
require 'spec_helper'
require 'date'


describe "Role" do

  it "Create" do
    data = {
      'sectionid' => 1,
      'sectionname' => 'A Section',
      'sectionConfig' => '{}',
      'groupname' => 'A Group',
      'groupid' => '2',
      'groupNormalised' => '3',
      'isDefault' => '1',
      'permissions' => {}
    }
    role = Osm::Role.new(data)

    role.section.id.should == 1
    role.section.name.should == 'A Section'
    role.group_id.should == 2
    role.group_name.should == 'A Group'
  end


  it "Compares two matching roles" do
    role1 = Osm::Role.new({'sectionConfig' => '{}'})
    role2 = Osm::Role.new({'sectionConfig' => '{}'})
    role1.should == role2
  end

  it "Compares two non-matching roles" do
    role1 = Osm::Role.new({'sectionid' => 1, 'sectionConfig' => '{}'})
    role2 = Osm::Role.new({'sectionid' => 2, 'sectionConfig' => '{}'})

    role1.should_not == role2
  end


  it "Sorts by Group Name then section type (age order)" do
    role1 = Osm::Role.new({'groupname' => 'Group A', 'sectionConfig' => '{}'})
    role2 = Osm::Role.new({'groupname' => 'Group B', 'sectionConfig' => '{"sectionType":"beavers"}'})
    role3 = Osm::Role.new({'groupname' => 'Group B', 'sectionConfig' => '{"sectionType":"cubs"}'})
    role4 = Osm::Role.new({'groupname' => 'Group B', 'sectionConfig' => '{"sectionType":"scouts"}'})
    role5 = Osm::Role.new({'groupname' => 'Group B', 'sectionConfig' => '{"sectionType":"explorers"}'})
    role6 = Osm::Role.new({'groupname' => 'Group B', 'sectionConfig' => '{"sectionType":"waiting"}'})
    role7 = Osm::Role.new({'groupname' => 'Group B', 'sectionConfig' => '{"sectionType":"adults"}'})
    role8 = Osm::Role.new({'groupname' => 'Group C', 'sectionConfig' => '{}'})

    data = [role8, role5, role3, role7, role2, role4, role1, role6]
    data.sort.should == [role1, role2, role3, role4, role5, role6, role7, role8]
  end


  it "Provides a long name for the role" do
    role = Osm::Role.new({
      'sectionname' => 'A Section',
      'sectionConfig' => '{}',
      'groupname' => 'A Group',
    })
    role.long_name.should == 'A Section (A Group)'

    role = Osm::Role.new({
      'sectionname' => 'A Section',
      'sectionConfig' => '{}',
    })
    role.long_name.should == 'A Section'
  end


  it "Provides a full name for the role" do
    role = Osm::Role.new({
      'sectionname' => 'A Section',
      'sectionConfig' => '{}',
      'groupname' => 'A Group',
    })
    role.full_name.should == 'A Group A Section'

    role = Osm::Role.new({
      'sectionname' => 'A Section',
      'sectionConfig' => '{}',
    })
    role.full_name.should == 'A Section'
  end


  it "Allows interegation of the permissions hash" do
    role = Osm::Role.new({
      'sectionConfig' => '{}',
      'permissions' => {
        'read_only' => 10,
        'read_write' => 20,
        'administer' => 100
      }
    })

    role.can_read?(:read_only).should == true
    role.can_read?(:read_write).should == true
    role.can_read?(:administer).should == true

    role.can_write?(:read_only).should == false
    role.can_write?(:read_write).should == true
    role.can_write?(:administer).should == true

    role.can_read?(:non_existant).should == false
    role.can_write?(:non_existant).should == false
  end

end