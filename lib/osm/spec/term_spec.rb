# encoding: utf-8
require 'spec_helper'
require 'date'

describe "Term" do

  it "Create" do
    data = {
      'termid' => '1',
      'sectionid' => '2',
      'name' => 'Term name',
      'startdate' => '2001-01-01',
      'enddate' => '2001-03-31'
    }
    term = Osm::Term.new(data)

    term.id.should == 1
    term.section_id.should == 2
    term.name.should == 'Term name'
    term.start.should == Date.new(2001, 1, 1)
    term.end.should == Date.new(2001, 3, 31)
  end


  it "Compares two matching terms" do
    data = {
      'termid' => '1',
      'sectionid' => '2',
      'name' => 'Term name',
      'startdate' => '2001-01-01',
      'enddate' => '2001-03-31'
    }
    term1 = Osm::Term.new(data)
    term2 = Osm::Term.new(data)
    term1.should == term2
  end

  it "Compares two non-matching terms" do
    data = {
      'termid' => '1',
      'sectionid' => '2',
      'name' => 'Term name',
      'startdate' => '2001-01-01',
      'enddate' => '2001-03-31'
    }
    term = Osm::Term.new(data)

    term.should_not == Osm::Term.new(data.merge('termid' => '3'))
  end


  it "Sorts by Section ID, Start date and then Term ID" do
    data = {
      'name' => 'Term name',
    }
    term1 = Osm::Term.new(data.merge('sectionid' => '1', 'termid' => '11', 'startdate' => (Date.today - 60).strftime('%Y-%m-%d'), 'enddate' => (Date.today - 1).strftime('%Y-%m-%d')))
    term2 = Osm::Term.new(data.merge('sectionid' => '1', 'termid' => '12', 'startdate' => (Date.today -  0).strftime('%Y-%m-%d'), 'enddate' => (Date.today + 0).strftime('%Y-%m-%d')))
    term3 = Osm::Term.new(data.merge('sectionid' => '1', 'termid' => '13', 'startdate' => (Date.today +  1).strftime('%Y-%m-%d'), 'enddate' => (Date.today + 60).strftime('%Y-%m-%d')))
    term4 = Osm::Term.new(data.merge('sectionid' => '2', 'termid' => '1', 'startdate' => (Date.today +  1).strftime('%Y-%m-%d'), 'enddate' => (Date.today + 60).strftime('%Y-%m-%d')))
    term5 = Osm::Term.new(data.merge('sectionid' => '2', 'termid' => '2', 'startdate' => (Date.today +  1).strftime('%Y-%m-%d'), 'enddate' => (Date.today + 60).strftime('%Y-%m-%d')))

    data = [term5, term3, term2, term4, term1]
    data.sort.should == [term1, term2, term3, term4, term5]
  end


  it "Works out if it is completly before a date" do
    data = {
      'termid' => '1',
      'sectionid' => '2',
      'name' => 'Term name',
    }
    term1 = Osm::Term.new(data.merge('startdate' => (Date.today - 60).strftime('%Y-%m-%d'), 'enddate' => (Date.today - 1).strftime('%Y-%m-%d')))
    term2 = Osm::Term.new(data.merge('startdate' => (Date.today -  0).strftime('%Y-%m-%d'), 'enddate' => (Date.today + 0).strftime('%Y-%m-%d')))
    term3 = Osm::Term.new(data.merge('startdate' => (Date.today +  1).strftime('%Y-%m-%d'), 'enddate' => (Date.today + 60).strftime('%Y-%m-%d')))

    term1.before?(Date.today).should == true
    term2.before?(Date.today).should == false
    term3.before?(Date.today).should == false
  end


  it "Works out if it is completly after a date" do
    data = {
      'termid' => '1',
      'sectionid' => '2',
      'name' => 'Term name',
    }
    term1 = Osm::Term.new(data.merge('startdate' => (Date.today - 60).strftime('%Y-%m-%d'), 'enddate' => (Date.today - 1).strftime('%Y-%m-%d')))
    term2 = Osm::Term.new(data.merge('startdate' => (Date.today -  0).strftime('%Y-%m-%d'), 'enddate' => (Date.today + 0).strftime('%Y-%m-%d')))
    term3 = Osm::Term.new(data.merge('startdate' => (Date.today +  1).strftime('%Y-%m-%d'), 'enddate' => (Date.today + 60).strftime('%Y-%m-%d')))

    term1.after?(Date.today).should == false
    term2.after?(Date.today).should == false
    term3.after?(Date.today).should == true
  end


  it "Works out if it has passed" do
    data = {
      'termid' => '1',
      'sectionid' => '2',
      'name' => 'Term name',
    }
    term1 = Osm::Term.new(data.merge('startdate' => (Date.today - 60).strftime('%Y-%m-%d'), 'enddate' => (Date.today - 1).strftime('%Y-%m-%d')))
    term2 = Osm::Term.new(data.merge('startdate' => (Date.today -  0).strftime('%Y-%m-%d'), 'enddate' => (Date.today + 0).strftime('%Y-%m-%d')))
    term3 = Osm::Term.new(data.merge('startdate' => (Date.today +  1).strftime('%Y-%m-%d'), 'enddate' => (Date.today + 60).strftime('%Y-%m-%d')))

    term1.past?().should == true
    term2.past?().should == false
    term3.past?().should == false
  end


  it "Works out if it is in the future" do
    data = {
      'termid' => '1',
      'sectionid' => '2',
      'name' => 'Term name',
    }
    term1 = Osm::Term.new(data.merge('startdate' => (Date.today - 60).strftime('%Y-%m-%d'), 'enddate' => (Date.today - 1).strftime('%Y-%m-%d')))
    term2 = Osm::Term.new(data.merge('startdate' => (Date.today -  0).strftime('%Y-%m-%d'), 'enddate' => (Date.today + 0).strftime('%Y-%m-%d')))
    term3 = Osm::Term.new(data.merge('startdate' => (Date.today +  1).strftime('%Y-%m-%d'), 'enddate' => (Date.today + 60).strftime('%Y-%m-%d')))

    term1.future?().should == false
    term2.future?().should == false
    term3.future?().should == true
  end


  it "Works out if it is the current term" do
    data = {
      'termid' => '1',
      'sectionid' => '2',
      'name' => 'Term name',
    }
    term1 = Osm::Term.new(data.merge('startdate' => (Date.today - 60).strftime('%Y-%m-%d'), 'enddate' => (Date.today - 1).strftime('%Y-%m-%d')))
    term2 = Osm::Term.new(data.merge('startdate' => (Date.today -  0).strftime('%Y-%m-%d'), 'enddate' => (Date.today + 0).strftime('%Y-%m-%d')))
    term3 = Osm::Term.new(data.merge('startdate' => (Date.today +  1).strftime('%Y-%m-%d'), 'enddate' => (Date.today + 60).strftime('%Y-%m-%d')))

    term1.current?().should == false
    term2.current?().should == true
    term3.current?().should == false
  end


  it "Works out if it contains a date" do
    data = {
      'termid' => '1',
      'sectionid' => '2',
      'name' => 'Term name',
    }
    term1 = Osm::Term.new(data.merge('startdate' => (Date.today - 60).strftime('%Y-%m-%d'), 'enddate' => (Date.today - 1).strftime('%Y-%m-%d')))
    term2 = Osm::Term.new(data.merge('startdate' => (Date.today -  0).strftime('%Y-%m-%d'), 'enddate' => (Date.today + 0).strftime('%Y-%m-%d')))
    term3 = Osm::Term.new(data.merge('startdate' => (Date.today +  1).strftime('%Y-%m-%d'), 'enddate' => (Date.today + 60).strftime('%Y-%m-%d')))

    term1.contains_date?(Date.today).should == false
    term2.contains_date?(Date.today).should == true
    term3.contains_date?(Date.today).should == false
  end

end