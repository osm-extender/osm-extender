# encoding: utf-8
require 'spec_helper'
require 'date'


class DummyRole
  attr_reader :id
  def initialize(id)
    @id = id
  end
  def <=>(another)
    @id <=> another.try(:id)
  end
end



describe "Section" do

  it "Create" do
    data = {
      'subscription_level' => '3',
      'subscription_expires' => (Date.today + 60).strftime('%Y-%m-%d'),
      'sectionType' => 'cubs',
      'numscouts' => 10,
      'hasUsedBadgeRecords' => '1',
      'hasProgramme' => true,
      'wizard' => 'False',
      'columnNames' => {},
      'fields' => {},
      'intouch' => {},
      'mobFields' => {},
      'extraRecords' => [],
    }
    role = DummyRole.new(1)
    section = Osm::Section.new(1, 'Name', data, role)

    section.id.should == 1
    section.name.should == 'Name' 
    section.subscription_level.should == :gold
    section.subscription_expires.should == Date.today + 60
    section.type.should == :cubs
    section.num_scouts.should == 10
    section.has_badge_records.should == true
    section.has_programme.should == true
    section.wizard.should == false
    section.column_names.should == {}
    section.fields.should == {}
    section.intouch_fields.should == {}
    section.mobile_fields.should == {}
    section.extra_records.should == []
    section.role.should == role
  end

  it "Create has sensible defaults" do
    section = Osm::Section.new(1, 'Name', {}, nil)

    section.subscription_level.should == :unknown
    section.subscription_expires.should == nil
    section.type.should == :unknown
    section.num_scouts.should == nil
    section.column_names.should == {}
    section.fields.should == {}
    section.intouch_fields.should == {}
    section.mobile_fields.should == {}
    section.extra_records.should == []
  end


  it "Compares two matching sections" do
    data = {
      'subscription_level' => '3',
      'subscription_expires' => (Date.today + 60).strftime('%Y-%m-%d'),
      'sectionType' => 'cubs',
      'numscouts' => '10',
      'hasUsedBadgeRecords' => '1',
      'hasProgramme' => true,
      'wizard' => 'False',
      'columnNames' => {},
      'fields' => {},
      'intouch' => {},
      'mobFields' => {},
      'extraRecords' => [],
    }
    role = DummyRole.new(1)
    section1 = Osm::Section.new(1, 'Name', data, role)
    section2 = section1.clone

    section1.should == section2
  end

  it "Compares two non-matching sections" do
    data = {
      'subscription_level' => '3',
      'subscription_expires' => (Date.today + 60).strftime('%Y-%m-%d'),
      'sectionType' => 'cubs',
      'numscouts' => '10',
      'hasUsedBadgeRecords' => '1',
      'hasProgramme' => true,
      'wizard' => 'False',
      'columnNames' => {},
      'fields' => {},
      'intouch' => {},
      'mobFields' => {},
      'extraRecords' => [],
    }
    role = DummyRole.new(1)
    section1 = Osm::Section.new(1, 'Name', data, role)
    section2 = Osm::Section.new(2, 'Name', data, role)

    section1.should_not == section2
  end


  it "Sorts by role" do
    data = {
      'subscription_level' => '3',
      'subscription_expires' => (Date.today + 60).strftime('%Y-%m-%d'),
      'sectionType' => 'cubs',
      'numscouts' => '10',
      'hasUsedBadgeRecords' => '1',
      'hasProgramme' => true,
      'wizard' => 'False',
      'columnNames' => {},
      'fields' => {},
      'intouch' => {},
      'mobFields' => {},
      'extraRecords' => [],
    }
    section1 = Osm::Section.new(1, 'Name', data, DummyRole.new(1))
    section2 = Osm::Section.new(1, 'Name', data, DummyRole.new(2))

    [section2, section1].sort.should == [section1, section2]
  end


  it "Correctly works out the section type" do
    data = {
      'subscription_level' => '3',
      'subscription_expires' => (Date.today + 60).strftime('%Y-%m-%d'),
      'numscouts' => '10',
      'hasUsedBadgeRecords' => '1',
      'hasProgramme' => true,
      'wizard' => 'False',
      'columnNames' => {},
      'fields' => {},
      'intouch' => {},
      'mobFields' => {},
      'extraRecords' => [],
    }

    unknown =   Osm::Section.new(1, 'Name', data, DummyRole.new(1))
    beavers =   Osm::Section.new(2, 'Name', data.merge('sectionType' => 'beavers'), DummyRole.new(2))
    cubs =      Osm::Section.new(3, 'Name', data.merge('sectionType' => 'cubs'), DummyRole.new(3))
    scouts =    Osm::Section.new(4, 'Name', data.merge('sectionType' => 'scouts'), DummyRole.new(4))
    explorers = Osm::Section.new(5, 'Name', data.merge('sectionType' => 'explorers'), DummyRole.new(5))
    adults =    Osm::Section.new(6, 'Name', data.merge('sectionType' => 'adults'), DummyRole.new(6))
    waiting =   Osm::Section.new(7, 'Name', data.merge('sectionType' => 'waiting'), DummyRole.new(7))

    {:beavers => beavers, :cubs => cubs, :scouts => scouts, :explorers => explorers, :adults => adults, :waiting => waiting, :unknwoon => unknown}.each do |section_type, section|
      [:beavers, :cubs, :scouts, :explorers, :adults, :waiting].each do |type|
        section.send("#{type.to_s}?").should == (section_type == type)
      end
    end
  end


  it "Correctly works out if the section is a youth section" do
    data = {
      'subscription_level' => '3',
      'subscription_expires' => (Date.today + 60).strftime('%Y-%m-%d'),
      'numscouts' => '10',
      'hasUsedBadgeRecords' => '1',
      'hasProgramme' => true,
      'wizard' => 'False',
      'columnNames' => {},
      'fields' => {},
      'intouch' => {},
      'mobFields' => {},
      'extraRecords' => [],
    }

    unknown =   Osm::Section.new(1, 'Name', data, DummyRole.new(1))
    beavers =   Osm::Section.new(2, 'Name', data.merge('sectionType' => 'beavers'), DummyRole.new(2))
    cubs =      Osm::Section.new(3, 'Name', data.merge('sectionType' => 'cubs'), DummyRole.new(3))
    scouts =    Osm::Section.new(4, 'Name', data.merge('sectionType' => 'scouts'), DummyRole.new(4))
    explorers = Osm::Section.new(5, 'Name', data.merge('sectionType' => 'explorers'), DummyRole.new(5))
    adults =    Osm::Section.new(6, 'Name', data.merge('sectionType' => 'adults'), DummyRole.new(6))
    waiting =   Osm::Section.new(7, 'Name', data.merge('sectionType' => 'waiting'), DummyRole.new(7))

    [beavers, cubs, scouts, explorers].each do |section|
      section.youth_section?.should == true
    end
    [adults, waiting, unknown].each do |section|
      section.youth_section?.should == false
    end
  end

end