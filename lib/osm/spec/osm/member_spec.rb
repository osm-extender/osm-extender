# encoding: utf-8
require 'spec_helper'

describe "Member" do

  it "Create" do
    data = {
      'scoutid' => 1,
      'sectionid' => 2,
      'type' => '',
      'firstname' => 'First',
      'lastname' => 'Last',
      'email1' => 'email1@example.com',
      'email2' => 'email2@example.com',
      'email3' => 'email3@example.com',
      'email4' => 'email4@example.com',
      'phone1' => '11111 111111',
      'phone2' => '222222',
      'phone3' => '+33 3333 333333',
      'phone4' => '4444 444 444',
      'address' => '1 Some Road',
      'address2' => '',
      'dob' => '2000-01-02',
      'started' => '2006-01-02',
      'joining_in_yrs' => '2',
      'parents' => 'John and Jane Doe',
      'notes' => 'None',
      'medical' => 'Nothing',
      'religion' => 'Unknown',
      'school'=> 'Some School',
      'ethnicity' => 'Yes',
      'subs' => 'Upto end of 2007',
      'patrolid' => '3',
      'patrolleader' => 0,
      'joined' => '2006-01-07',
      'age' => '06/07',
      'yrs' => 1,
      'patrol' => 'Blue',
    }
    member = Osm::Member.new(data)

    member.id.should == 1
    member.section_id.should == 2
    member.type.should == ''
    member.first_name.should == 'First'
    member.last_name.should == 'Last'
    member.email1.should == 'email1@example.com'
    member.email2.should == 'email2@example.com'
    member.email3.should == 'email3@example.com'
    member.email4.should == 'email4@example.com'
    member.phone1.should == '11111 111111'
    member.phone2.should == '222222'
    member.phone3.should == '+33 3333 333333'
    member.phone4.should == '4444 444 444'
    member.address.should == '1 Some Road'
    member.address2.should == ''
    member.date_of_birth.should == Date.new(2000, 1, 2)
    member.started.should == Date.new(2006, 1, 2)
    member.joined_in_years.should == 2
    member.parents.should == 'John and Jane Doe'
    member.notes.should == 'None'
    member.medical.should == 'Nothing'
    member.religion.should == 'Unknown'
    member.school.should == 'Some School'
    member.ethnicity.should == 'Yes'
    member.subs.should == 'Upto end of 2007'
    member.grouping_id.should == 3
    member.grouping_leader.should == 0
    member.joined.should == Date.new(2006, 1, 7)
    member.age.should == '06/07'
    member.joined_years.should == 1
    member.patrol.should == 'Blue'
  end


  it "Provides member's full name" do
    data = {
      'firstname' => 'First',
      'lastname' => 'Last',
    }
    member = Osm::Member.new(data)

    member.name.should == 'First Last'
    member.name('_').should == 'First_Last'
  end


  it "Provides each part of age" do
    data = {
      'age' => '06/07',
    }
    member = Osm::Member.new(data)

    member.age_years.should == 6
    member.age_months.should == 7
  end

end