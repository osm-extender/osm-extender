# encoding: utf-8
require 'spec_helper'


class DummyHttpResult
  def initialize(options={})
    @response = DummyHttpResponse.new(options[:response])
  end
  def response
    @response
  end
end
class DummyHttpResponse
  def initialize(options={})
    @options = options
  end
  def code
    @options[:code]
  end
  def body
    @options[:body]
  end
end


describe "API" do

  before(:each) do
    @api_config = {
      :api_id => '1',
      :api_token => 'API TOKEN',
      :api_name => 'API NAME',
      :api_site => :scout,
    }.freeze
    Osm::Api.configure(@api_config)
  end

  it "Create" do
    api = Osm::Api.new

    api.nil?.should == false
    Osm::Api.api_id.should == @api_config[:api_id]
    Osm::Api.api_name.should == @api_config[:api_name]
  end

  it "Raises errors on bad arguents to configure" do
    # Missing options
    expect{ Osm::Api.configure(@api_config.select{ |k,v| (k != :api_id )}) }.to raise_error(ArgumentError, ':api_id does not exist in options hash')
    expect{ Osm::Api.configure(@api_config.select{ |k,v| (k != :api_token)}) }.to raise_error(ArgumentError, ':api_token does not exist in options hash')
    expect{ Osm::Api.configure(@api_config.select{ |k,v| (k != :api_name)}) }.to raise_error(ArgumentError, ':api_name does not exist in options hash')
    expect{ Osm::Api.configure(@api_config.select{ |k,v| (k != :api_site)}) }.to raise_error(ArgumentError, ':api_site does not exist in options hash or is invalid, this should be set to either :scout or :guide')

    # Invalid site
    expect{ Osm::Api.configure(@api_config.select{ |k,v| (k != :api_site)}.merge(:api_site => :invalid)) }.to raise_error(ArgumentError, ':api_site does not exist in options hash or is invalid, this should be set to either :scout or :guide')

    # Invalid default_cache_ttl
    expect{ Osm::Api.configure(@api_config.merge(:default_cache_ttl => -1)) }.to raise_error(ArgumentError, ':default_cache_ttl must be greater than 0')
    expect{ Osm::Api.configure(@api_config.merge(:default_cache_ttl => 'invalid')) }.to raise_error(ArgumentError, ':default_cache_ttl must be greater than 0')
  end


  it "Raises errors on bad arguments to create" do
    # Both userid and secret (or neither) must be passed
    expect{ Osm::Api.new('1') }.to raise_error(ArgumentError, 'You must pass a secret if you are passing a userid')
    expect{ Osm::Api.new(nil, '1') }.to raise_error(ArgumentError, 'You must pass a userid if you are passing a secret')

    expect{ Osm::Api.new('1', '2', :invalid_site) }.to raise_error(ArgumentError, 'site is invalid, if passed it should be either :scout or :guide')
  end


  it "authorizes a user to use the OSM API" do
    user_email = 'alice@example.com'
    user_password = 'alice'

    url = 'https://www.onlinescoutmanager.co.uk/users.php?action=authorise'
    post_data = {
      'apiid' => @api_config[:api_id],
      'token' => @api_config[:api_token],
      'email' => user_email,
      'password' => user_password,
    }
    HTTParty.should_receive(:post).with(url, {:body => post_data}) { DummyHttpResult.new(:response=>{:code=>'200', :body=>'{"userid":"id","secret":"secret"}'}) }

    Osm::Api.new.authorize(user_email, user_password).should == {'userid' => 'id', 'secret' => 'secret'}
  end



  describe "Using the API:" do
    it "Fetches the user's roles" do
      body = [
        {"sectionConfig"=>"{\"subscription_level\":\"3\",\"subscription_expires\":\"2013-01-05\",\"sectionType\":\"cubs\",\"columnNames\":{\"phone1\":\"Home Phone\",\"phone2\":\"Parent 1 Phone\",\"address\":\"Member's Address\",\"phone3\":\"Parent 2 Phone\",\"address2\":\"Address 2\",\"phone4\":\"Alternate Contact Phone\",\"subs\":\"Gender\",\"email1\":\"Parent 1 Email\",\"medical\":\"Medical / Dietary\",\"email2\":\"Parent 2 Email\",\"ethnicity\":\"Gift Aid\",\"email3\":\"Member's Email\",\"religion\":\"Religion\",\"email4\":\"Email 4\",\"school\":\"School\"},\"numscouts\":10,\"hasUsedBadgeRecords\":true,\"hasProgramme\":true,\"extraRecords\":[{\"name\":\"Subs\",\"extraid\":\"529\"}],\"wizard\":\"false\",\"fields\":{\"email1\":true,\"email2\":true,\"email3\":true,\"email4\":false,\"address\":true,\"address2\":false,\"phone1\":true,\"phone2\":true,\"phone3\":true,\"phone4\":true,\"school\":false,\"religion\":true,\"ethnicity\":true,\"medical\":true,\"patrol\":true,\"subs\":true,\"saved\":true},\"intouch\":{\"address\":true,\"address2\":false,\"email1\":false,\"email2\":false,\"email3\":false,\"email4\":false,\"phone1\":true,\"phone2\":true,\"phone3\":true,\"phone4\":true,\"medical\":false},\"mobFields\":{\"email1\":false,\"email2\":false,\"email3\":false,\"email4\":false,\"address\":true,\"address2\":false,\"phone1\":true,\"phone2\":true,\"phone3\":true,\"phone4\":true,\"school\":false,\"religion\":false,\"ethnicity\":true,\"medical\":true,\"patrol\":true,\"subs\":false}}", "groupname"=>"1st Somewhere", "groupid"=>"1", "groupNormalised"=>"1", "sectionid"=>"1", "sectionname"=>"Section 1", "section"=>"cubs", "isDefault"=>"1", "permissions"=>{"badge"=>100, "member"=>100, "user"=>100, "register"=>100, "contact"=>100, "programme"=>100, "originator"=>1, "events"=>100, "finance"=>100, "flexi"=>100}},
        {"sectionConfig"=>"{\"subscription_level\":\"3\",\"subscription_expires\":\"2013-01-05\",\"sectionType\":\"cubs\",\"columnNames\":{\"phone1\":\"Home Phone\",\"phone2\":\"Parent 1 Phone\",\"address\":\"Member's Address\",\"phone3\":\"Parent 2 Phone\",\"address2\":\"Address 2\",\"phone4\":\"Alternate Contact Phone\",\"subs\":\"Gender\",\"email1\":\"Parent 1 Email\",\"medical\":\"Medical / Dietary\",\"email2\":\"Parent 2 Email\",\"ethnicity\":\"Gift Aid\",\"email3\":\"Member's Email\",\"religion\":\"Religion\",\"email4\":\"Email 4\",\"school\":\"School\"},\"numscouts\":10,\"hasUsedBadgeRecords\":true,\"hasProgramme\":true,\"extraRecords\":[],\"wizard\":\"false\",\"fields\":{\"email1\":true,\"email2\":true,\"email3\":true,\"email4\":false,\"address\":true,\"address2\":false,\"phone1\":true,\"phone2\":true,\"phone3\":true,\"phone4\":true,\"school\":false,\"religion\":true,\"ethnicity\":true,\"medical\":true,\"patrol\":true,\"subs\":true,\"saved\":true},\"intouch\":{\"address\":true,\"address2\":false,\"email1\":false,\"email2\":false,\"email3\":false,\"email4\":false,\"phone1\":true,\"phone2\":true,\"phone3\":true,\"phone4\":true,\"medical\":false},\"mobFields\":{\"email1\":false,\"email2\":false,\"email3\":false,\"email4\":false,\"address\":true,\"address2\":false,\"phone1\":true,\"phone2\":true,\"phone3\":true,\"phone4\":true,\"school\":false,\"religion\":false,\"ethnicity\":true,\"medical\":true,\"patrol\":true,\"subs\":false}}", "groupname"=>"1st Somewhere", "groupid"=>"1", "groupNormalised"=>"1", "sectionid"=>"2", "sectionname"=>"Section 2", "section"=>"cubs", "isDefault"=>"0", "permissions"=>{"badge"=>100, "member"=>100, "user"=>100, "register"=>100, "contact"=>100, "programme"=>100, "originator"=>1, "events"=>100, "finance"=>100, "flexi"=>100}}
      ]
      FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/api.php?action=getUserRoles", :body => body.to_json)

      roles = Osm::Api.new('1', '2').get_roles
      roles.size.should == 2
      roles[0].is_a?(Osm::Role).should be_true
      roles[0].section.id.should_not == roles[1].section.id
      roles[0].group_id.should == roles[1].group_id
    end


    it "Fetch the user's notepads" do
      FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/api.php?action=getNotepads", :body => {"1" => "Section 1", "2" => "Section 2"}.to_json)
      Osm::Api.new('1', '2').get_notepads.should == {'1' => 'Section 1', '2' => 'Section 2'}
    end


    it "Fetch the notepad for a section" do
      FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/api.php?action=getNotepads", :body => {"1" => "Section 1", "2" => "Section 2"}.to_json)
      Osm::Api.new('1', '2').get_notepad(1).should == 'Section 1'
    end


    it "Fetch a section's details" do
      body = [
        {"sectionConfig"=>"{\"subscription_level\":\"3\",\"subscription_expires\":\"2013-01-05\",\"sectionType\":\"cubs\",\"columnNames\":{\"phone1\":\"Home Phone\",\"phone2\":\"Parent 1 Phone\",\"address\":\"Member's Address\",\"phone3\":\"Parent 2 Phone\",\"address2\":\"Address 2\",\"phone4\":\"Alternate Contact Phone\",\"subs\":\"Gender\",\"email1\":\"Parent 1 Email\",\"medical\":\"Medical / Dietary\",\"email2\":\"Parent 2 Email\",\"ethnicity\":\"Gift Aid\",\"email3\":\"Member's Email\",\"religion\":\"Religion\",\"email4\":\"Email 4\",\"school\":\"School\"},\"numscouts\":10,\"hasUsedBadgeRecords\":true,\"hasProgramme\":true,\"extraRecords\":[{\"name\":\"Subs\",\"extraid\":\"529\"}],\"wizard\":\"false\",\"fields\":{\"email1\":true,\"email2\":true,\"email3\":true,\"email4\":false,\"address\":true,\"address2\":false,\"phone1\":true,\"phone2\":true,\"phone3\":true,\"phone4\":true,\"school\":false,\"religion\":true,\"ethnicity\":true,\"medical\":true,\"patrol\":true,\"subs\":true,\"saved\":true},\"intouch\":{\"address\":true,\"address2\":false,\"email1\":false,\"email2\":false,\"email3\":false,\"email4\":false,\"phone1\":true,\"phone2\":true,\"phone3\":true,\"phone4\":true,\"medical\":false},\"mobFields\":{\"email1\":false,\"email2\":false,\"email3\":false,\"email4\":false,\"address\":true,\"address2\":false,\"phone1\":true,\"phone2\":true,\"phone3\":true,\"phone4\":true,\"school\":false,\"religion\":false,\"ethnicity\":true,\"medical\":true,\"patrol\":true,\"subs\":false}}", "groupname"=>"1st Somewhere", "groupid"=>"1", "groupNormalised"=>"1", "sectionid"=>"1", "sectionname"=>"Section 1", "section"=>"cubs", "isDefault"=>"1", "permissions"=>{"badge"=>100, "member"=>100, "user"=>100, "register"=>100, "contact"=>100, "programme"=>100, "originator"=>1, "events"=>100, "finance"=>100, "flexi"=>100}},
        {"sectionConfig"=>"{\"subscription_level\":\"3\",\"subscription_expires\":\"2013-01-05\",\"sectionType\":\"cubs\",\"columnNames\":{\"phone1\":\"Home Phone\",\"phone2\":\"Parent 1 Phone\",\"address\":\"Member's Address\",\"phone3\":\"Parent 2 Phone\",\"address2\":\"Address 2\",\"phone4\":\"Alternate Contact Phone\",\"subs\":\"Gender\",\"email1\":\"Parent 1 Email\",\"medical\":\"Medical / Dietary\",\"email2\":\"Parent 2 Email\",\"ethnicity\":\"Gift Aid\",\"email3\":\"Member's Email\",\"religion\":\"Religion\",\"email4\":\"Email 4\",\"school\":\"School\"},\"numscouts\":10,\"hasUsedBadgeRecords\":true,\"hasProgramme\":true,\"extraRecords\":[],\"wizard\":\"false\",\"fields\":{\"email1\":true,\"email2\":true,\"email3\":true,\"email4\":false,\"address\":true,\"address2\":false,\"phone1\":true,\"phone2\":true,\"phone3\":true,\"phone4\":true,\"school\":false,\"religion\":true,\"ethnicity\":true,\"medical\":true,\"patrol\":true,\"subs\":true,\"saved\":true},\"intouch\":{\"address\":true,\"address2\":false,\"email1\":false,\"email2\":false,\"email3\":false,\"email4\":false,\"phone1\":true,\"phone2\":true,\"phone3\":true,\"phone4\":true,\"medical\":false},\"mobFields\":{\"email1\":false,\"email2\":false,\"email3\":false,\"email4\":false,\"address\":true,\"address2\":false,\"phone1\":true,\"phone2\":true,\"phone3\":true,\"phone4\":true,\"school\":false,\"religion\":false,\"ethnicity\":true,\"medical\":true,\"patrol\":true,\"subs\":false}}", "groupname"=>"1st Somewhere", "groupid"=>"1", "groupNormalised"=>"1", "sectionid"=>"2", "sectionname"=>"Section 2", "section"=>"cubs", "isDefault"=>"0", "permissions"=>{"badge"=>100, "member"=>100, "user"=>100, "register"=>100, "contact"=>100, "programme"=>100, "originator"=>1, "events"=>100, "finance"=>100, "flexi"=>100}}
      ]
      FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/api.php?action=getUserRoles", :body => body.to_json)

      section = Osm::Api.new('1', '2').get_section(2)
      section.is_a?(Osm::Section).should be_true
      section.id.should == 2
    end


    it "Fetch a section's groupings (sixes, patrols etc.)" do
      body = {"patrols" => [
        {"patrolid" => "101","name" => "Group 1","active" => 1},
        {"patrolid" => "106","name" => "Group 2","active" => 1},
        {"patrolid" => "107","name" => "Group 3","active" => 0},
      ]}
      FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/users.php?action=getPatrols&sectionid=2", :body => body.to_json)

      groupings = Osm::Api.new('1', '2').get_groupings(2)
      groupings.size.should == 3
      groupings[0].is_a?(Osm::Grouping).should be_true
    end


    it "Fetch terms" do
      body = {
        "9" => [
          {"termid" => "1", "name" => "Term 1", "sectionid" => "9", "startdate" => (Date.today + 31).strftime('%Y-%m-%d'), "enddate" => (Date.today + 90).strftime('%Y-%m-%d')}
        ],
        "10" => [
          {"termid" => "2", "name" => "Term 2", "sectionid" => "10", "startdate" => (Date.today + 31).strftime('%Y-%m-%d'), "enddate" => (Date.today + 90).strftime('%Y-%m-%d')},
          {"termid" => "3", "name" => "Term 3", "sectionid" => "10", "startdate" => (Date.today + 91).strftime('%Y-%m-%d'), "enddate" => (Date.today + 180).strftime('%Y-%m-%d')}
        ]
      }
      FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/api.php?action=getTerms", :body => body.to_json)

      terms = Osm::Api.new('1', '2').get_terms
      terms.size.should == 3
      terms[0].is_a?(Osm::Term).should be_true
    end


    it "Fetch a term" do
      body = {
        "9" => [
          {"termid" => "1", "name" => "Term 1", "sectionid" => "9", "startdate" => (Date.today + 31).strftime('%Y-%m-%d'), "enddate" => (Date.today + 90).strftime('%Y-%m-%d')}
        ],
        "10" => [
          {"termid" => "2", "name" => "Term 2", "sectionid" => "10", "startdate" => (Date.today + 31).strftime('%Y-%m-%d'), "enddate" => (Date.today + 90).strftime('%Y-%m-%d')},
          {"termid" => "3", "name" => "Term 3", "sectionid" => "10", "startdate" => (Date.today + 91).strftime('%Y-%m-%d'), "enddate" => (Date.today + 180).strftime('%Y-%m-%d')}
        ]
      }
      FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/api.php?action=getTerms", :body => body.to_json)

      term = Osm::Api.new('1', '2').get_term(2)
      term.is_a?(Osm::Term).should be_true
      term.id.should == 2
    end


    it "Fetch the term's programme for a section" do
      items = [{"eveningid" => "5", "sectionid" =>"3", "title" => "Weekly Meeting 1", "notesforparents" => "", "games" => "", "prenotes" => "", "postnotes" => "", "leaders" => "", "meetingdate" => "2001-02-03", "starttime" => "19:15:00", "endtime" => "20:30:00", "googlecalendar" => ""}]
      activities = {"5" => [
        {"activityid" => "6", "title" => "Activity 6", "notes" => "", "eveningid" => "5"},
        {"activityid" => "7", "title" => "Activity 7", "notes" => "", "eveningid" => "5"}
      ]}
      body = {"items" => items, "activities" => activities}
      FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/programme.php?action=getProgramme&sectionid=3&termid=4", :body => body.to_json)

      programme = Osm::Api.new('1', '2').get_programme(3, 4)
      programme.size.should == 1
      programme[0].is_a?(Osm::ProgrammeItem).should be_true
      programme[0].activities.size.should == 2
    end


    it "Fetch an activity" do
      body = {
        'details' => {
          'activityid' => "1",
          'version' => '0',
          'groupid' => '1',
          'userid' => '1',
          'title' => "Activity 1",
          'description' => '',
          'resources' => '',
          'instructions' => '',
          'runningtime' => '',
          'location' => 'indoors',
          'shared' => '0',
          'rating' => '0',
          'facebook' => ''
        },
        'editable'=>false,
        'rating'=>'0',
        'used'=>'2',
        'versions' => [
          {
            'value' => '0',
            'userid' => '1',
            'firstname' => 'Alice',
            'label' => 'Current version - Alice',
            'selected' => 'selected'
          }
        ],
        'sections'=> ['beavers', 'cubs', 'scouts', 'explorers'],
        'tags' => ""
      }

      FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/programme.php?action=getActivity&id=1", :body => body.to_json)
      FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/programme.php?action=getActivity&id=1&version=0", :body => body.to_json)

      activity = Osm::Api.new('1', '2').get_activity(1)
      activity.id.should == 1

      activity0 = Osm::Api.new('1', '2').get_activity(1, 0)
      activity0.id.should == 1
    end


    it "Fetch members' details" do
      body = {
        'identifier' => 'scoutid',
        'items' => [{
          'scoutid' => '1', 'sectionid' => '1', 'type' => '',
          'firstname' => 'John', 'lastname' => 'Doe',
          'email1' => '', 'email2' => '', 'email3' => '', 'email4' => '',
          'phone1' => '', 'phone2' => '', 'phone3' => '', 'phone4' => '', 'address' => '', 'address2' => '',
          'dob' => '2001-02-03', 'started' => '2006-01-01', 'joining_in_yrs' => '-1',
          'parents' => '', 'notes' => '', 'medical' => '', 'religion' => '', 'school' => '', 'ethnicity' => '',
          'subs' => '', 'patrolid' => '1', 'patrolleader' => '0', 'joined' => '2006-01-01',
          'age' => '6 / 0', 'yrs' => '9', 'patrol' => '1'
        }]
      }

      FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/users.php?action=getUserDetails&sectionid=1&termid=2", :body => body.to_json)
      members = Osm::Api.new('1', '2').get_members(1, 2)
      members[0].id.should == '1'
    end


    it "Fetch the API Access for a section" do
      body = {
        'apis' => [{
          'apiid' => '1',
          'name' => 'Test API',
          'permissions' => {}
        }]
      }
      FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/users.php?action=getAPIAccess&sectionid=1", :body => body.to_json)
      apis = Osm::Api.new('1', '2').get_api_access(1)
      apis[0].id.should == '1'
    end


    it "Fetch our API Access for a section" do
      body = {
        'apis' => [{
          'apiid' => '1',
          'name' => 'Test API',
          'permissions' => {}
        },{
          'apiid' => '2',
          'name' => 'Test API 2',
          'permissions' => {}
        }]
      }
      FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/users.php?action=getAPIAccess&sectionid=1", :body => body.to_json)
      api = Osm::Api.new('1', '2').get_our_api_access(1)
      api.id.should == '1'
    end

    it "Fetch our API Access for a section (not in returned data)" do
      body = {
        'apis' => []
      }
      FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/users.php?action=getAPIAccess&sectionid=1", :body => body.to_json)
      api = Osm::Api.new('1', '2').get_our_api_access(1)
      api.should be_nil
    end


    it "Fetch events for a section" do
      body = {
        'identifier' => 'eventid',
        'label' => 'name',
        'items' => [{
          'eventid' => '1',
          'name' => 'An Event',
          'startdate' => '2001-02-03',
          'enddate' => nil,
          'starttime' => '00:00:00',
          'endtime' => '00:00:00',
          'cost' => '0.00',
          'location' => '',
          'notes' => '',
          'sectionid' => 1,
          'googlecalendar' => nil
        }]
      }
      FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/events.php?action=getEvents&sectionid=1", :body => body.to_json)
      events = Osm::Api.new('1', '2').get_events(1)
      events[0].id.should == '1'
    end


    it "Fetch due badges for a section" do
      badges_body = []
      roles_body = [{
        "sectionConfig" => "{\"subscription_level\":\"3\",\"subscription_expires\":\"2013-01-05\",\"sectionType\":\"cubs\",\"columnNames\":{\"phone1\":\"Home Phone\",\"phone2\":\"Parent 1 Phone\",\"address\":\"Member\'s Address\",\"phone3\":\"Parent 2 Phone\",\"address2\":\"Address 2\",\"phone4\":\"Alternate Contact Phone\",\"subs\":\"Gender\",\"email1\":\"Parent 1 Email\",\"medical\":\"Medical / Dietary\",\"email2\":\"Parent 2 Email\",\"ethnicity\":\"Gift Aid\",\"email3\":\"Member\'s Email\",\"religion\":\"Religion\",\"email4\":\"Email 4\",\"school\":\"School\"},\"numscouts\":10,\"hasUsedBadgeRecords\":true,\"hasProgramme\":true,\"extraRecords\":[{\"name\":\"Subs\",\"extraid\":\"529\"}],\"wizard\":\"false\",\"fields\":{\"email1\":true,\"email2\":true,\"email3\":true,\"email4\":false,\"address\":true,\"address2\":false,\"phone1\":true,\"phone2\":true,\"phone3\":true,\"phone4\":true,\"school\":false,\"religion\":true,\"ethnicity\":true,\"medical\":true,\"patrol\":true,\"subs\":true,\"saved\":true},\"intouch\":{\"address\":true,\"address2\":false,\"email1\":false,\"email2\":false,\"email3\":false,\"email4\":false,\"phone1\":true,\"phone2\":true,\"phone3\":true,\"phone4\":true,\"medical\":false},\"mobFields\":{\"email1\":false,\"email2\":false,\"email3\":false,\"email4\":false,\"address\":true,\"address2\":false,\"phone1\":true,\"phone2\":true,\"phone3\":true,\"phone4\":true,\"school\":false,\"religion\":false,\"ethnicity\":true,\"medical\":true,\"patrol\":true,\"subs\":false}}",
        "groupname" => "1st Somewhere", "groupid" => "1 ","groupNormalised" => "1",
        "sectionid" => "1", "sectionname" => "Section 1", "section" => "cubs", "isDefault" => "1",
        "permissions" => {"badge"=>100,"member"=>100,"user"=>100,"register"=>100,"contact"=>100,"programme"=>100,"originator"=>1,"events"=>100,"finance"=>100,"flexi"=>100}
      }]
      FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/api.php?action=getUserRoles", :body => roles_body.to_json)
      FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/challenges.php?action=outstandingBadges&section=cubs&sectionid=1&termid=2", :body => badges_body.to_json)

      due_badges = Osm::Api.new('1', '2').get_due_badges(1, 2)
      due_badges.should_not be_nil
    end


    it "Fetch the register structure for a section" do
      data = [
        {"rows" => [{"name"=>"First name","field"=>"firstname","width"=>"100px"},{"name"=>"Last name","field"=>"lastname","width"=>"100px"},{"name"=>"Total","field"=>"total","width"=>"60px"}],"noscroll"=>true},
        {"rows" => []}
      ]
      FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/users.php?action=registerStructure&sectionid=1&termid=2", :body => data.to_json)

      register_structure = Osm::Api.new('1', '2').get_register_structure(1, 2)
      register_structure.is_a?(Array).should be_true
    end

    it "Fetch the register data for a section" do
      data = {
        'identifier' => 'scoutid',
        'label' => "name",
        'items' => []
      }
      FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/users.php?action=register&sectionid=1&termid=2", :body => data.to_json)

      register = Osm::Api.new('1', '2').get_register(1, 2)
      register.is_a?(Array).should be_true
    end



    it "Create an evening (succeded)" do
      url = 'https://www.onlinescoutmanager.co.uk/programme.php?action=addActivityToProgramme'
      post_data = {
        'apiid' => @api_config[:api_id],
        'token' => @api_config[:api_token],
        'userid' => 'user',
        'secret' => 'secret',
        'meetingdate' => '2012-07-29',
        'sectionid' => 1,
        'activityid' => -1,
      }

      api = Osm::Api.new('user', 'secret')
      api.stub(:get_terms) { [] }
      HTTParty.should_receive(:post).with(url, {:body => post_data}) { DummyHttpResult.new(:response=>{:code=>'200', :body=>'{"result":0}'}) }
      api.create_evening(1, Date.today).should be_true
    end

    it "Create an evening (failed)" do
      url = 'https://www.onlinescoutmanager.co.uk/programme.php?action=addActivityToProgramme'
      post_data = {
        'apiid' => @api_config[:api_id],
        'token' => @api_config[:api_token],
        'userid' => 'user',
        'secret' => 'secret',
        'meetingdate' => '2012-07-29',
        'sectionid' => 1,
        'activityid' => -1,
      }

      api = Osm::Api.new('user', 'secret')
      api.stub(:get_terms) { [] }
      HTTParty.should_receive(:post).with(url, {:body => post_data}) { DummyHttpResult.new(:response=>{:code=>'200', :body=>'{"result":1}'}) }
      api.create_evening(1, Date.today).should be_false
    end


    it "Update an evening (succeded)" do
      url = 'https://www.onlinescoutmanager.co.uk/programme.php?action=editEvening'
      post_data = {
        'apiid' => @api_config[:api_id],
        'token' => @api_config[:api_token],
        'userid' => 'user',
        'secret' => 'secret',
        'eveningid' => nil, 'sectionid' => nil, 'meetingdate' => nil, 'starttime' => nil,
        'endtime' => nil, 'title' => 'Unnamed meeting', 'notesforparents' =>'', 'prenotes' => '',
        'postnotes' => '', 'games' => '', 'leaders' => '', 'activity' => '[]', 'googlecalendar' => '',
      }
      api = Osm::Api.new('user', 'secret')
      api.stub(:get_terms) { [] }
      HTTParty.should_receive(:post).with(url, {:body => post_data}) { DummyHttpResult.new(:response=>{:code=>'200', :body=>'{"result":0}'}) }

      programme_item = Osm::ProgrammeItem.new({}, [])
      api.update_evening(programme_item).should be_true
    end

    it "Update an evening (failed)" do
      url = 'https://www.onlinescoutmanager.co.uk/programme.php?action=editEvening'
      post_data = {
        'apiid' => @api_config[:api_id],
        'token' => @api_config[:api_token],
        'userid' => 'user',
        'secret' => 'secret',
        'eveningid' => nil, 'sectionid' => nil, 'meetingdate' => nil, 'starttime' => nil,
        'endtime' => nil, 'title' => 'Unnamed meeting', 'notesforparents' =>'', 'prenotes' => '',
        'postnotes' => '', 'games' => '', 'leaders' => '', 'activity' => '[]', 'googlecalendar' => '',
      }
      api = Osm::Api.new('user', 'secret')
      api.stub(:get_terms) { [] }
      HTTParty.should_receive(:post).with(url, {:body => post_data}) { DummyHttpResult.new(:response=>{:code=>'200', :body=>'{"result":1}'}) }

      programme_item = Osm::ProgrammeItem.new({}, [])
      api.update_evening(programme_item).should be_false
    end
  end


  describe "Options Hash" do
    it "Uses the API's user and secret when not passed" do
      url = "https://www.onlinescoutmanager.co.uk/api.php?action=getNotepads"
      post_data = {
        'apiid' => @api_config[:api_id],
        'token' => @api_config[:api_token],
        'userid' => 'user',
        'secret' => 'secret',
      }

      HTTParty.should_receive(:post).with(url, {:body => post_data}) { DummyHttpResult.new(:response=>{:code=>'200', :body=>'{"1":"Section 1"}'}) }
      Osm::Api.new('user', 'secret').get_notepads.should == {'1' => 'Section 1'}
    end

    it "Uses the user and secret passed in" do
      url = "https://www.onlinescoutmanager.co.uk/api.php?action=getNotepads"
      post_data = {
        'apiid' => @api_config[:api_id],
        'token' => @api_config[:api_token],
        'userid' => 'user',
        'secret' => 'secret',
      }

      HTTParty.should_receive(:post).with(url, {:body => post_data}) { DummyHttpResult.new(:response=>{:code=>'200', :body=>'{"1":"Section 1"}'}) }
      Osm::Api.new('1', '2').get_notepads(:api_data => {'userid'=>'user', 'secret'=>'secret'}).should == {'1' => 'Section 1'}
    end
  end


  describe "Caching behaviour:" do
    it "Controls access to items in the cache (forbids if unknown)" do
      api1 = Osm::Api.new('1', 'secret')
      api2 = Osm::Api.new('2', 'secret')

      body = {"9" => [{"termid" => "1", "name" => "Term 1", "sectionid" => "9", "startdate" => (Date.today + 31).strftime('%Y-%m-%d'), "enddate" => (Date.today + 90).strftime('%Y-%m-%d')}]}

      FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/api.php?action=getTerms", :body => body.to_json)
      terms = api1.get_terms
      FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/api.php?action=getTerms", :body => {}.to_json)
      api2.get_term(terms[0].id).should be_nil
    end

    it "Controls access to items in the cache (allows if known)" do
      api1 = Osm::Api.new('1', 'secret')
      api2 = Osm::Api.new('2', 'secret')

      body = {"9" => [{"termid" => "1", "name" => "Term 1", "sectionid" => "9", "startdate" => (Date.today + 31).strftime('%Y-%m-%d'), "enddate" => (Date.today + 90).strftime('%Y-%m-%d')}]}

      FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/api.php?action=getTerms", :body => body.to_json)
      terms = api1.get_terms
      api1.get_term(terms[0].id).should_not be_nil
      api2.get_term(terms[0].id).should_not be_nil
    end


    it "Fetches from the cache when the cache holds it" do
      url = "https://www.onlinescoutmanager.co.uk/api.php?action=getNotepads"
      post_data = {
        'apiid' => @api_config[:api_id],
        'token' => @api_config[:api_token],
        'userid' => 'user',
        'secret' => 'secret',
      }

      # Fetch first time (and 'prime' the cache)
      HTTParty.should_receive(:post).with(url, {:body => post_data}) { DummyHttpResult.new(:response=>{:code=>'200', :body=> {"1" => "Section 1"}.to_json}) }
      Osm::Api.new('user', 'secret').get_notepad(1).should == 'Section 1'

      # Fetch second time
      HTTParty.should_not_receive(:post)
      Osm::Api.new('user', 'secret').get_notepad(1).should == 'Section 1'
    end

    it "Doesn't fetch from the cache when told not to" do
      url = "https://www.onlinescoutmanager.co.uk/api.php?action=getNotepads"
      post_data = {
        'apiid' => @api_config[:api_id],
        'token' => @api_config[:api_token],
        'userid' => 'user',
        'secret' => 'secret',
      }

      # Fetch first time (and 'prime' the cache)
      HTTParty.should_receive(:post).with(url, {:body => post_data}) { DummyHttpResult.new(:response=>{:code=>'200', :body=>'{"1":"Section 1"}'}) }
      Osm::Api.new('user', 'secret').get_notepad(1).should == 'Section 1'

      # Fetch second time
      HTTParty.should_receive(:post).with(url, {:body => post_data}) { DummyHttpResult.new(:response=>{:code=>'200', :body=>'{"1":"New content."}'}) }
      Osm::Api.new('user', 'secret').get_notepad(1, {:no_cache => true}).should == 'New content.'
    end
  end


  describe "OSM and Internet error conditions:" do
    it "Raises a connection error if the HTTP status code was not 'OK'" do
      HTTParty.stub(:post) { DummyHttpResult.new(:response=>{:code=>'500'}) }
      expect{ Osm::Api.new.authorize('email@example.com', 'password') }.to raise_error(Osm::ConnectionError, 'HTTP Status code was 500')
    end


    it "Raises a connection error if it can't connect to OSM" do
      HTTParty.stub(:post) { raise SocketError }
      expect{ Osm::Api.new.authorize('email@example.com', 'password') }.to raise_error(Osm::ConnectionError, 'A problem occured on the internet.')
    end


    it "Raises an error if OSM returns an error (as a hash)" do
      HTTParty.stub(:post) { DummyHttpResult.new(:response=>{:code=>'200', :body=>'{"error":"Error message"}'}) }
      expect{ Osm::Api.new.authorize('email@example.com', 'password') }.to raise_error(Osm::Error, 'Error message')
    end

    it "Raises an error if OSM returns an error (as a plain string)" do
      HTTParty.stub(:post) { DummyHttpResult.new(:response=>{:code=>'200', :body=>'Error message'}) }
      expect{ Osm::Api.new.authorize('email@example.com', 'password') }.to raise_error(Osm::Error, 'Error message')
    end
  end

end