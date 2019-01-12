Given /^an OSM request to "([^"]*)" will work$/ do |description|
  url = get_osm_url(description)
  FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/#{url}", :body => get_osm_body(description), :content_type => 'application/json') unless url.nil?
end

Given /^an OSM request to "([^"]*)" will not work$/ do |description|
  url = get_osm_url(description)
  FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/#{url}", :body => '{"error":"A simulated OSM API error occured"}', :content_type => 'application/json') unless url.nil?
end

Given /^"([^"]*)" is connected to OSM$/ do |email|
  user = User.find_by_email_address(email)
  user.osm_userid = 1234
  user.osm_secret = 5678
  user.save!
end

Given /^an OSM request to "get roles" will give (\d+) (?:(beaver|cub|scout|explorer|adult|waiting) )?roles?$/ do |roles, type|
  type ||= 'cub'
  type = "#{type}s" unless type.eql?('waiting')
  roles = roles.to_i

  body = '['
  (1..roles).each do |role|
    body += '{"sectionConfig":"{\"subscription_level\":\"3\",\"subscription_expires\":\"2013-01-05\",\"sectionType\":\"' + type + '\",\"columnNames\":{\"phone1\":\"Home Phone\",\"phone2\":\"Parent 1 Phone\",\"address\":\"Member\'s Address\",\"phone3\":\"Parent 2 Phone\",\"address2\":\"Address 2\",\"phone4\":\"Alternate Contact Phone\",\"subs\":\"Gender\",\"email1\":\"Parent 1 Email\",\"medical\":\"Medical / Dietary\",\"email2\":\"Parent 2 Email\",\"ethnicity\":\"Gift Aid\",\"email3\":\"Member\'s Email\",\"religion\":\"Religion\",\"email4\":\"Email 4\",\"school\":\"School\"},\"numscouts\":10,\"hasUsedBadgeRecords\":true,\"hasProgramme\":true,\"extraRecords\":[{\"name\":\"Flexi 1\",\"extraid\":\"' + role.to_s + '01\"},{\"name\":\"Flexi 2\",\"extraid\":\"' + role.to_s + '02\"}],\"wizard\":\"false\",\"fields\":{\"email1\":true,\"email2\":true,\"email3\":true,\"email4\":false,\"address\":true,\"address2\":false,\"phone1\":true,\"phone2\":true,\"phone3\":true,\"phone4\":true,\"school\":false,\"religion\":true,\"ethnicity\":true,\"medical\":true,\"patrol\":true,\"subs\":true,\"saved\":true},\"intouch\":{\"address\":true,\"address2\":false,\"email1\":false,\"email2\":false,\"email3\":false,\"email4\":false,\"phone1\":true,\"phone2\":true,\"phone3\":true,\"phone4\":true,\"medical\":false},\"mobFields\":{\"email1\":false,\"email2\":false,\"email3\":false,\"email4\":false,\"address\":true,\"address2\":false,\"phone1\":true,\"phone2\":true,\"phone3\":true,\"phone4\":true,\"school\":false,\"religion\":false,\"ethnicity\":true,\"medical\":true,\"patrol\":true,\"subs\":false}}","groupname":"1st Somewhere","groupid":"1","groupNormalised":"1","sectionid":"' + role.to_s + '","sectionname":"Section ' + role.to_s + '","section":"cubs","isDefault":"' + (role == 1 ? '1' : '0') + '","permissions":{"badge":100,"member":100,"user":100,"register":100,"contact":100,"programme":100,"originator":1,"events":100,"finance":100,"flexi":100}},'
  end
  body[-1] = ']'

  FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/api.php?action=getUserRoles", :body => body, :content_type => 'application/json')
end

Given /^an OSM request to get sections will give (\d+) sections?$/ do |sections|
  url = 'api.php?action=getSectionConfig'

  sections = sections.to_i
  data = {}
  (1..sections).each do |section|
    data[section.to_s] = {
      "subscription_level"=>"3", "subscription_expires"=>"2013-01-05", "sectionType"=>"cubs",
      "columnNames"=>{"phone1"=>"Phone 1", "phone2"=>"Phone 2", "address"=>"Address", "phone3"=>"Phone 3", "address2"=>"Address 2", "phone4"=>"Phone 4", "subs"=>"Subs", "email1"=>"Email 1", "medical"=>"Medical / Dietary", "email2"=>"Email 2", "ethnicity"=>"Ethnicity", "email3"=>"Email 3", "religion"=>"Religion", "email4"=>"Email 4", "school"=>"School"},
      "numscouts"=>11, "hasUsedBadgeRecords"=>true, "hasProgramme"=>true,
      "extraRecords"=>[{"name"=>"Extra Record #{section.to_s}", "extraid"=>section.to_s}],
      "wizard"=>"false",
      "fields"=>{"email1"=>true, "email2"=>true, "email3"=>true, "email4"=>false, "address"=>true, "address2"=>false, "phone1"=>true, "phone2"=>true, "phone3"=>true, "phone4"=>true, "school"=>false, "religion"=>true, "ethnicity"=>true, "medical"=>true, "patrol"=>true, "subs"=>true, "saved"=>true},
      "intouch"=>{"address"=>true, "address2"=>false, "email1"=>false, "email2"=>false, "email3"=>false, "email4"=>false, "phone1"=>true, "phone2"=>true, "phone3"=>true, "phone4"=>true, "medical"=>false},
      "mobFields"=>{"email1"=>false, "email2"=>false, "email3"=>false, "email4"=>false, "address"=>true, "address2"=>false, "phone1"=>true, "phone2"=>true, "phone3"=>true, "phone4"=>true, "school"=>false, "religion"=>false, "ethnicity"=>true, "medical"=>true, "patrol"=>true, "subs"=>false}
    }
  end

  FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/#{url}", :body => data.to_json, :content_type => 'application/json')
end


Given /^an OSM request to get_api_access for section "([^"]*)" will have the permissions$/ do |section, table|
  values = {
    'none' => '0',
    'read' => '10',
    'write' => '20',
    'administer' => '100',
  }

  body = {
    'apis' => [{
      'apiid' => '12',
      'name' => 'Test API',
      'permissions' => Hash[table.hashes.map { |hash|
        [hash['permission'], values.fetch(hash['granted'])]
      }]
    }]
  }.to_json

  FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/ext/settings/access/?action=getAPIAccess&sectionid=#{section}", :body => body, :content_type => 'application/json')
end

Given /^an OSM request to get_flexi_record_fields for section "(\d+)" flexi "(\d+)" will have the fields$/ do |section, flexi, table|
  fields = Array.new
  table.hashes.each do |hash|
    fields.push ({
      'field' => hash['id'],
      'name' => hash['name'],
      'width' => "150",
      'editable' => !!hash['editable']
    })
  end

  body = {
    'structure' => [
      {
        'rows' => [
          {'name' => 'First name','field' => 'firstname','width' => '150px'},
          {'name' => 'Last name','field' => 'lastname','width' => '150px'},
        ],
        'noscroll' => true
      },{
        'rows' => fields
      }
    ]
  }

  FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/extras.php?action=getExtra&sectionid=#{section}&extraid=#{flexi}", :body => body.to_json, :content_type => 'application/json')
end

Given /^an OSM request to get_flexi_record_data for section "(\d+)" flexi "(\d+)" term "(\d+)" will have the data$/ do |section, flexi, term, table|
  data = Array.new
  table.hashes.each_with_index do |hash, index|
    data.push ({
      'scoutid' => index.to_s,
      'dob' => '',
      'patrolid' => '1',
      'total' => '',
      'completed' => '',
      'age' => '',
      'patrol' => 'Patrol Name'
    }.merge(hash))
  end

  body = {
    'identifier' => 'scoutid',
    'label' => 'name',
    'items' => data,
  }

  FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/extras.php?action=getExtraRecords&sectionid=#{section}&extraid=#{flexi}&termid=#{term}&section=cubs", :body => body.to_json, :content_type => 'application/json')
end


Given /^an OSM request to get members for section (\d+) in term (\d+) will have the members?$/ do |section_id, term_id, table|
  url = "ext/members/contact/grid/?action=getMembers"

  members = Array.new
  members_summary = Array.new
  table.hashes.each_with_index do |hash, index|
    id = index + 1
    members.push ({
      :id => id.to_s,
      :first_name => hash['first_name'] || 'A',
      :last_name => hash['last_name'] || 'Member',
      :grouping_id => hash['grouping_id'].to_s,
      :date_of_birth => hash['date_of_birth'].blank? ? 9.years.ago.strftime("%y-%m-%d") : hash['date_of_birth'].to_s,
      :contact_email1 => hash['contact_email1'].to_s,
      :contact_email2 => hash['contact_email2'].to_s,
      :primary_email1 => hash['primary_email1'].to_s,
      :primary_email2 => hash['primary_email2'].to_s,
      :secondary_email1 => hash['secondary_email1'].to_s,
      :secondary_email2 => hash['secondary_email2'].to_s,
      :emergency_email1 => hash['emergency_email1'].to_s,
      :emergency_email2 => hash['emergency_email2'].to_s,
    })
  end

  body = '{"data":{'
  members.each do |member|
    body += '"' + member[:id] + '":{"first_name":"' + member[:first_name] + '","last_name":"' + member[:last_name] + '","patrol_id":"' + member[:grouping_id] + '","date_of_birth":"' + member[:date_of_birth] + '","custom_data":{"1":{"12":"' + member[:primary_email1] + '","14":"' + member[:primary_email2] + '"},"2":{"12":"' + member[:secondary_email1] + '","14":"' + member[:secondary_email2] + '"},"3":{"12":"' + member[:emergency_email1] + '","14":"' + member[:emergency_email2] + '"},"4":{},"5":{},"6":{"12":"' + member[:contact_email1] + '","14":"' + member[:contact_email2] + '"},"7":{}}},'
  end
  body[-1] = '}'
  body += ',"meta":{"structure":[{"group_id":1,"columns":[]},{"group_id":2,"columns":[]},{"group_id":3,"columns":[]},{"group_id":4,"columns":[]},{"group_id":6,"columns":[]},{"group_id":5,"columns":[]},{"group_id":7,"columns":[]}]}}'

  FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/#{url}", :body => body, :content_type => 'application/json')
end

Given /^an OSM request to get events for section (\d+) will have the events$/ do |section_id, table|
  url = "events.php?action=getEvents&sectionid=#{section_id}&showArchived=true"

  events = Array.new
  table.hashes.each_with_index do |hash, index|
    event = {
      "eventid" => (index + 1).to_s,
      "name" => hash['name'],
      "startdate" => hash['in how many days'].to_i.days.from_now.strftime('%Y-%m-%d'),
      "enddate" => nil,
      "starttime" => "00:00:00",
      "endtime" => "00:00:00",
      "cost" => "0.00",
      "location" => "",
      "notes" => "",
      "sectionid" => section_id,
      "googlecalendar" => nil
    }
    events.push event
  end

  data = {
    "identifier" => "eventid",
    "label" => "name",
    "items" => events
  }

  FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/#{url}", :body => data.to_json, :content_type => 'application/json')
end

Given /^an OSM request to get event (\d+) in section (\d+) will have the fields$/ do |event_id, section_id, table|
  url = "events.php?action=getEvent&sectionid=#{section_id}&eventid=#{event_id}"

  fields = Array.new
  table.hashes.each_with_index do |hash, index|
    field = {
      'id' => hash['id'],
      'name' => hash['label'],
    }
    fields.push event
  end
  FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/#{url}", :body => {'config' => fields.to_json}.to_json, :content_type => 'application/json')
end

Given /^an OSM request to get event (\d+) in section (\d+) will have no fields$/ do |event_id, section_id|
  url = "events.php?action=getEvent&sectionid=#{section_id}&eventid=#{event_id}"
  FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/#{url}", :body => {'config' => [].to_json}.to_json, :content_type => 'application/json')
end


Given /^an OSM request to get the register structure for term (\d+) and section (\d+) will cover the last (\d+) weeks$/ do |term_id, section_id, weeks|
  weeks = weeks.to_i
  url = "users.php?action=registerStructure&sectionid=#{section_id}&termid=#{term_id}"

  rows = []
  range = 1..weeks
  range = range.to_a.reverse
  range.each_with_index do |ago, index|
    date = ago.weeks.ago.strftime('%Y-%m-%d')
    row = {
      "name" => date,
      "field" => date,
      "formatter" => "doneFormatter",
      "width" => "110px",
      "tooltip" => "Programme Item #{index}"
    }
    rows.push row
  end
  
  data = [
    {"rows"=>[{"name"=>"First name","field"=>"firstname","width"=>"100px"},{"name"=>"Last name","field"=>"lastname","width"=>"100px"},{"name"=>"Total","field"=>"total","width"=>"60px"}],"noscroll"=>true},
    {"rows"=>rows}
  ]

  FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/#{url}", :body => data.to_json, :content_type => 'application/json')
end

Given /^an OSM request to get the register for term (\d+) and section (\d+) will have the following members and attendance$/ do |term_id, section_id, table|
  url = "users.php?action=register&sectionid=#{section_id}&termid=#{term_id}"

  rows = []
  table.hashes.each_with_index do |hash, index|
    from_weeks_ago = hash['from weeks ago'].to_i
    to_weeks_ago = hash['to weeks ago'].to_i
    row = {
      'scoutid' => (index + 1).to_s,
      'firstname' => hash['name'],
      'lastname' => 'Smith',
      'sectionid' => section_id,
      'patrolid' => '1',
      'total' => from_weeks_ago - to_weeks_ago
    }
    range = from_weeks_ago..to_weeks_ago
    range.each do |ago|
      row[ago.weeks.ago.strftime('%Y-%m-%d')] = '1'
    end
    rows.push row
  end


  
  data = {
    'identifier' => 'scoutid',
    'label' => "name",
    'items' => rows
  }

  FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/#{url}", :body => data.to_json, :content_type => 'application/json')
end

Given /^an OSM request to get due badges for section (\d+) and term (\d+) will result in the following being due their "([^"]*)" badge$/ do |section_id, term_id, badge_name, table|
  url = "ext/badges/due/?action=get&section=cubs&sectionid=#{section_id}&termid=#{term_id}"
  badge_id = "#{rand(100)}_1"

  members = []
  table.hashes.each_with_index do |hash, index|
    scout_id = (index + 1).to_s
    member = {
      'badge_id' => badge_id,
      'badge_identifier' => '93_0',
      'badge_version' => '0',
      'completed' => '2',
      'current_stock' => '20',
      'extra' => (hash['completed'].empty? ? hash['extra'] : "Lvl #{hash['completed']}"),
      'firstname' => hash['name'],
      'label' => 'Staged',
      'lastname' => 'Smith',
      'name' => 'Participation',
      'patrolid' => '1502',
      'pic' => true,
      'picture' => '',
      'scout_id' => scout_id,
      'sid' => scout_id,
      'type_id' => '3',
    }
    members.push member
  end

  data = {
    'includeStock' => true,
    'count' => 1,
    'badgesToBuy' => 0,
    'description' => {
      badge_id => {
        'badge_identifier' => badge_id,
        'name' => badge_name,
        'picture' => '',
        'typeLabel' => 'Staged',
        'type_id' => 3
      }
    },
    'pending' => {
      badge_id => members,
    },
  }

  FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/#{url}", :body => data.to_json, :content_type => 'application/json')
end

Given /^an OSM request to get groupings for section (\d+) will have the groupings?$/ do |section_id, table|
  url = "users.php?action=getPatrols&sectionid=#{section_id}"

  groupings = Array.new
  table.hashes.each do |hash|
     groupings.push [hash['grouping_id'], hash['name']]
  end

  body = '{"patrols":['
  groupings.each do |grouping|
    body += "{\"patrolid\":\"#{grouping[0]}\",\"name\":\"#{grouping[1]}\",\"active\":1},"
  end
  body[-1] = ']'
  body += '}'

  FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/#{url}", :body => body, :content_type => 'application/json')
end

Given /^an OSM request to get terms for section (\d+) will have the terms?$/ do |section_id, table|
  terms = Array.new
  table.hashes.each do |hash|
     terms.push ({
      :id => hash['term_id'],
      :name => hash['name'],
      :start => hash['start'] || 1.month.ago.to_date.to_s('yyyy-mm-dd'),
      :end => hash['end'] || 1.month.from_now.to_date.to_s('yyyy-mm-dd'),
    })
  end

  body = '{"' + section_id.to_s + '":['
  terms.each do |term|
    body += "{\"termid\":\"#{term[:id]}\",\"name\":\"#{term[:name]}\",\"sectionid\":\"#{section_id}\",\"startdate\":\"#{term[:start]}\",\"enddate\":\"#{term[:end]}\"},"
  end
  body[-1] = ']'
  body += '}'

  FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/api.php?action=getTerms", :body => body, :content_type => 'application/json')
end

Given /^an OSM request to get terms for section (\d+) will have no terms$/ do |section_id|
  body = '{"' + section_id.to_s + '":[]}'
  FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/api.php?action=getTerms", :body => body, :content_type => 'application/json')
end

Given /^an OSM request to get terms will have the terms?$/ do |table|
  terms = Hash.new
  table.hashes.each do |hash|
     terms[hash['section_id']] ||= Array.new
     terms[hash['section_id']].push ({
      'sectionid' => hash['section_id'],
      'termid' => hash['term_id'],
      'name' => hash['name'],
      'startdate' => hash['start'] || 1.month.ago.to_date.to_s('yyyy-mm-dd'),
      'enddate' => hash['end'] || 1.month.from_now.to_date.to_s('yyyy-mm-dd'),
    })
  end
  FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/api.php?action=getTerms", :body => terms.to_json, :content_type => 'application/json')
end

Given /^an OSM request to get programme for section (\d+) term (\d+) will have (\d+) programme items?$/ do |section, term, items|
  url = "programme.php?action=getProgramme&sectionid=#{section}&termid=#{term}"
  items = items.to_i

  item = []
  (1..items).each do |n|
    item.push ({
      'eveningid' => "#{n}",
      'sectionid' => "#{section}",
      'title' => "Weekly Meeting #{n}",
      'notesforparents' => '',
      'games' => '',
      'prenotes' => '',
      'postnotes' => '',
      'leaders' => '',
      'meetingdate' => (Date.today + n.days).strftime ,
      'starttime' => '19:15:00',
      'endtime' => '20:30:00',
      'googlecalendar' => ''
    })
  end
  
  activity = {}
  (1..items).each do |n|
    act = []
    (1..items).each do |m|
      act.push ({
        "activityid" => "#{n}#{m}",
        "title" => "Activity #{n}#{m}",
        "notes" => "",
        "eveningid" => "#{n}"
      })
    end
    activity["#{n}"] = act
  end

  body = {
    'items' => item,
    'activities' => activity
  }

  FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/#{url}", :body => body.to_json, :content_type => 'application/json')
end

Given /^an OSM request to get activity (\d+) will have tags "(.+)"$/ do |activity_id, tags|
  url = "programme.php?action=getActivity&id=#{activity_id}"

  body = {
    'details' => {
      'activityid' => "#{activity_id}",
      'version' => '0',
      'groupid' => '1',
      'userid' => '1',
      'title' => "Activity #{activity_id}",
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
    'tags' => tags.split(', ')
  }

  FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/#{url}", :body => body.to_json, :content_type => 'application/json')
end

Given /^an OSM request to get the notepad for section (\d+) will give "(.+)"$/ do |section_id, notepad|
  FakeWeb.register_uri(:post, 'https://www.onlinescoutmanager.co.uk/api.php?action=getNotepads', :body => {section_id => {'raw' => notepad, 'html' => "<p>#{notepad}</p>"}}.to_json, :content_type => 'application/json')
end

Given /^an OSM request to add activity to programme will work$/ do
  FakeWeb.register_uri(:post, 'https://www.onlinescoutmanager.co.uk/programme.php?action=addActivityToProgramme', :body => '{"result":0}', :content_type => 'application/json')
end

Given /^an OSM request to get programme for section (\d+) term (\d+) will have the evenings?$/ do |section, term, table|
  evenings = Array.new
  table.hashes.each do |hash|
     evenings.push ({
      :id => hash['evening_id'],
      :date => hash['meeting_date'],
    })
  end

  url = "programme.php?action=getProgramme&sectionid=#{section}&termid=#{term}"
  items = Array.new
  evenings.each do |n|
    items.push ({
      'eveningid' => "#{n[:id]}",
      'sectionid' => "#{section}",
      'title' => "Unnamed meeting",
      'notesforparents' => '',
      'games' => '',
      'prenotes' => '',
      'postnotes' => '',
      'leaders' => '',
      'meetingdate' => n[:date],
      'starttime' => nil,
      'endtime' => nil,
      'googlecalendar' => '',
    })
  end

  activities = {}
  items.each do |n|
    activities["#{n}"] = []
  end
  
  body = {
    'items' => items,
    'activities' => activities
  }

  FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/#{url}", :body => body.to_json, :content_type => 'application/json')
end

Then /^"([^"]*)" should be connected to OSM$/ do |email|
  user = User.find_by_email_address(email)
  user.connected_to_osm?.should == true
end

Then /^"([^"]*)" should not be connected to OSM$/ do |email|
  user = User.find_by_email_address(email)
  user.connected_to_osm?.should == false
end


def get_osm_url(description)
  return 'users.php?action=authorise' if description.eql?('authorize')
  return 'api.php?action=getUserRoles' if description.eql?('get roles')
  return 'users.php?action=getAPIAccess' if description.eql?('get_api_access')
  return 'events.php?action=addEvent&sectionid=1' if description.eql?('create_event')
  return nil
end

def get_osm_body(description)
  return '{"secret":"abc123","userid":"1234"}' if description.eql?('authorize')
  return '{"id":1}' if description.eql?('create_event')
  return nil
end
