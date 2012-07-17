# encoding: utf-8
require 'spec_helper'
require 'date'

describe "Online Scout Manager" do

  describe "Make array of symbols" do
    it "turns array of strings to an array of symbols" do
      start = %w{first second third}
      Osm::make_array_of_symbols(start).should == [:first, :second, :third]
    end
  end


  describe "find current term ID" do
    it "Returns the current term for the section from all terms returned by OSM" do
      Osm::Api.configure({:api_id=>'1234', :api_token=>'12345678', :api_name=>'API', :api_site=>:scout})
      api = Osm::Api.new('2345', 'abcd')
      section_id = 9

      body = '{"9":['
      body += '{"termid":"1","name":"Term 1","sectionid":"9","startdate":"' + (Date.today - 90).strftime('%Y-%m-%d') + '","enddate":"' + (Date.today - 31).strftime('%Y-%m-%d') + '"},'
      body += '{"termid":"2","name":"Term 2","sectionid":"9","startdate":"' + (Date.today - 30).strftime('%Y-%m-%d') + '","enddate":"' + (Date.today + 30).strftime('%Y-%m-%d') + '"},'
      body += '{"termid":"3","name":"Term 3","sectionid":"9","startdate":"' + (Date.today + 31).strftime('%Y-%m-%d') + '","enddate":"' + (Date.today + 90).strftime('%Y-%m-%d') + '"}'
      body += ']}'
      FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/api.php?action=getTerms", :body => body)

      Osm::find_current_term_id(api, section_id).should == 2
    end

    it "Raises an error if there is no current term" do
      Osm::Api.configure({:api_id=>'1234', :api_token=>'12345678', :api_name=>'API', :api_site=>:scout})
      api = Osm::Api.new('2345', 'abcd')
      section_id = 9

      body = '{"9":['
      body += '{"termid":"1","name":"Term 1","sectionid":"9","startdate":"' + (Date.today + 31).strftime('%Y-%m-%d') + '","enddate":"' + (Date.today + 90).strftime('%Y-%m-%d') + '"}'
      body += ']}'
      FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/api.php?action=getTerms", :body => body)

      expect{ Osm::find_current_term_id(api, section_id) }.to raise_error(Osm::Error)
    end
  end


  describe "Make a DateTime" do
    it "is given a date and a time" do
      Osm::make_datetime('2001-02-03', '04:05:06').should == DateTime.new(2001, 02, 03, 04, 05, 06)
    end

    it "is given just a date" do
      Osm::make_datetime('2001-02-03', '').should == DateTime.new(2001, 02, 03, 00, 00, 00)
    end

    it "is given neither" do
      Osm::make_datetime('', '').should == nil
    end

    it "is given an invalid date" do
      Osm::make_datetime('No date here1', '04:05:06').should == nil
    end

    it "is given an invalid time" do
      Osm::make_datetime('2001-02-03', 'No time here!').should == nil
    end

    it "is given just an invalid date" do
      Osm::make_datetime('No date here1', nil).should == nil
    end
  end


  describe "Parse a date" do
    it "is given a valid date string" do
      Osm::parse_date('2001-02-03').should == Date.new(2001, 02, 03)
    end

    it "is given an invalid date string" do
      Osm::parse_date('No date here!').should == nil
    end
  end

end
