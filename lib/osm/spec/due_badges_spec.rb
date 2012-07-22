# encoding: utf-8
require 'spec_helper'

describe "Term" do

  it "Create" do
    data = {
      'pending' => {
        'badge_name' => [
          {
            'scoutid' => '1',
            'firstname' => 'John',
            'lastname' => 'Doe',
            'completed' => '',
            'extra' => '',
          }
        ],
        'cubs_core_participation' => [{
            'sid' => '2',
            'firstname' => 'Jane',
            'lastname' => 'Doe',
            'completed' => '3',
            'extra' => 'Lvl 3'
          }, {
            'sid' => '1',
            'firstname' => 'John',
            'lastname' => 'Doe',
            'completed' => '2',
            'extra' => 'Lvl 2'
          }
        ]
      },

      'description' => {
        'badge_name' => {
          'name' => 'Badge Name',
          'section' => 'cubs',
          'type' => 'activity',
          'badge' => 'badge_name'
        },
        'cubs_core_participation' => {
          'name' => 'Participation',
          'section' => 'cubs',
          'type' => 'core',
          'badge' => 'participation'
        }
      }
    }
    db = Osm::DueBadges.new(data)

    db.empty?.should == false
    db.descriptions.should == {:badge_name=>{:name=>"Badge Name", :section=>:cubs, :type=>:activity, :badge=>"badge_name"}, :cubs_core_participation=>{:name=>"Participation", :section=>:cubs, :type=>:core, :badge=>"participation"}}
    db.by_member.should == {"John Doe"=>[{:badge=>:badge_name, :extra_information=>""}, {:badge=>:cubs_core_participation, :extra_information=>"Lvl 2"}], "Jane Doe"=>[{:badge=>:cubs_core_participation, :extra_information=>"Lvl 3"}]}
    db.totals.should == {:badge_name=>{""=>1}, :cubs_core_participation=>{"Lvl 3"=>1, "Lvl 2"=>1}}
  end

end