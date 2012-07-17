# encoding: utf-8
require 'spec_helper'

describe "Online Scout Manager" do

  describe "Make array of symbols" do
    it "turns array of strings to an array of symbols" do
      start = %w{first second third}
      Osm::make_array_of_symbols(start).should == [:first, :second, :third]
    end
  end


  describe "find current term ID" do
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
