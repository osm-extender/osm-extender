Given /^an OSM request to "([^"]*)" will work$/ do |description|
  url = get_osm_url(description)
  FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/#{url}", :body => get_osm_body(description)) unless url.nil?
end

Given /^an OSM request to "([^"]*)" will not work$/ do |description|
  url = get_osm_url(description)
  FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/#{url}", :body => '{"error":"A simulated OSM API error occured"}') unless url.nil?
end

Given /^"([^"]*)" is connected to OSM$/ do |email|
  user = User.find_by_email_address(email)
  user.osm_userid = 1234
  user.osm_secret = 5678
  user.save!
end

Given /^an OSM request to "([^"]*)" will give (\d+) roles?$/ do |description, roles|
  roles = roles.to_i
  body = '['
  (1..roles).each do |role|
    body += '{"sectionConfig":"{\"subscription_level\":3,\"subscription_expires\":\"2013-01-05\",\"sectionType\":\"cubs\",\"columnNames\":{\"phone1\":\"Home Phone\",\"phone2\":\"Parent 1 Phone\",\"address\":\"Member\'s Address\",\"phone3\":\"Parent 2 Phone\",\"address2\":\"Address 2\",\"phone4\":\"Alternate Contact Phone\",\"subs\":\"Gender\",\"email1\":\"Parent 1 Email\",\"medical\":\"Medical / Dietary\",\"email2\":\"Parent 2 Email\",\"ethnicity\":\"Gift Aid\",\"email3\":\"Member\'s Email\",\"religion\":\"Religion\",\"email4\":\"Email 4\",\"school\":\"School\"},\"numscouts\":10,\"hasUsedBadgeRecords\":true,\"hasProgramme\":true,\"extraRecords\":[{\"name\":\"Subs\",\"extraid\":\"529\"}],\"wizard\":\"false\",\"fields\":{\"email1\":true,\"email2\":true,\"email3\":true,\"email4\":false,\"address\":true,\"address2\":false,\"phone1\":true,\"phone2\":true,\"phone3\":true,\"phone4\":true,\"school\":false,\"religion\":true,\"ethnicity\":true,\"medical\":true,\"patrol\":true,\"subs\":true,\"saved\":true},\"intouch\":{\"address\":true,\"address2\":false,\"email1\":false,\"email2\":false,\"email3\":false,\"email4\":false,\"phone1\":true,\"phone2\":true,\"phone3\":true,\"phone4\":true,\"medical\":false},\"mobFields\":{\"email1\":false,\"email2\":false,\"email3\":false,\"email4\":false,\"address\":true,\"address2\":false,\"phone1\":true,\"phone2\":true,\"phone3\":true,\"phone4\":true,\"school\":false,\"religion\":false,\"ethnicity\":true,\"medical\":true,\"patrol\":true,\"subs\":false}}","groupname":"1st Somewhere","groupid":"1","groupNormalised":"1","sectionid":"' + role.to_s + '","sectionname":"Section ' + role.to_s + '","section":"cubs","isDefault":"' + (role == 1 ? '1' : '0') + '","permissions":{"badge":100,"member":100,"user":100,"register":100,"contact":100,"programme":100,"originator":1,"events":100,"finance":100,"flexi":100}},'
  end
  body[-1] = ']'
  url = get_osm_url(description)
  FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/#{url}", :body => body) unless url.nil?
end

Given /^an OSM request to get sections will give (\d+) sections?$/ do |sections|
  url = 'api.php?action=getSectionConfig'

  sections = sections.to_i
  data = {}
  (1..sections).each do |section|
    data[section.to_s] = {
      "subscription_level"=>3, "subscription_expires"=>"2013-01-05", "sectionType"=>"cubs",
      "columnNames"=>{"phone1"=>"Phone 1", "phone2"=>"Phone 2", "address"=>"Address", "phone3"=>"Phone 3", "address2"=>"Address 2", "phone4"=>"Phone 4", "subs"=>"Subs", "email1"=>"Email 1", "medical"=>"Medical / Dietary", "email2"=>"Email 2", "ethnicity"=>"Ethnicity", "email3"=>"Email 3", "religion"=>"Religion", "email4"=>"Email 4", "school"=>"School"},
      "numscouts"=>11, "hasUsedBadgeRecords"=>true, "hasProgramme"=>true,
      "extraRecords"=>[{"name"=>"Extra Record #{section.to_s}", "extraid"=>section.to_s}],
      "wizard"=>"false",
      "fields"=>{"email1"=>true, "email2"=>true, "email3"=>true, "email4"=>false, "address"=>true, "address2"=>false, "phone1"=>true, "phone2"=>true, "phone3"=>true, "phone4"=>true, "school"=>false, "religion"=>true, "ethnicity"=>true, "medical"=>true, "patrol"=>true, "subs"=>true, "saved"=>true},
      "intouch"=>{"address"=>true, "address2"=>false, "email1"=>false, "email2"=>false, "email3"=>false, "email4"=>false, "phone1"=>true, "phone2"=>true, "phone3"=>true, "phone4"=>true, "medical"=>false},
      "mobFields"=>{"email1"=>false, "email2"=>false, "email3"=>false, "email4"=>false, "address"=>true, "address2"=>false, "phone1"=>true, "phone2"=>true, "phone3"=>true, "phone4"=>true, "school"=>false, "religion"=>false, "ethnicity"=>true, "medical"=>true, "patrol"=>true, "subs"=>false}
    }
  end

  FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/#{url}", :body => data.to_json)
end


Given /^an OSM request to get_api_access for section "([^"]*)" will have the permissions$/ do |section, table|

  permissions = Array.new
  table.hashes.each do |hash|
     permissions.push [hash['permission'], hash['granted']]
  end

  body = '{"apis":[{"apiid":"' + OSM::API.api_id + '","name":"Test API","permissions":{'
  permissions.each do |permission|
    permission[1] = 0 if permission[1].eql?('none')
    permission[1] = 10 if permission[1].eql?('read')
    permission[1] = 20 if permission[1].eql?('write') || permission[1].eql?('read/write')
    body += "\"#{permission[0]}\":\"#{permission[1]}\","
  end
  body[-1] = '}'
  body += '}]}'

  url = get_osm_url('get_api_access')
  FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/#{url}&sectionid=#{section}", :body => body) unless url.nil?
end

Given /^an OSM request to get members for section (\d+) in term (\d+) will have the members$/ do |section_id, term_id, table|
  url = "users.php?action=getUserDetails&sectionid=#{section_id}&termid=#{term_id}"

  members = Array.new
  table.hashes.each do |hash|
     members.push [hash['email1'], hash['email2'], hash['email3'], hash['email4'], hash['grouping_id']]
  end

  body = '{"identifier":"scoutid","items":['
  members.each do |member|
    body += "{\"scoutid\":\"1\",\"sectionid\":\"#{section_id}\",\"type\":\"\",\"firstname\":\"A\",\"lastname\":\"Member\",\"email1\":\"#{member[0]}\",\"email2\":\"#{member[1]}\",\"email3\":\"#{member[2]}\",\"email4\":\"#{member[3]}\",\"phone1\":\"\",\"phone2\":\"\",\"phone3\":\"\",\"phone4\":\"\",\"address\":\"\",\"address2\":\"\",\"dob\":\"2000-01-01\",\"started\":\"2006-01-01\",\"joining_in_yrs\":\"-1\",\"parents\":\"\",\"notes\":\"\",\"medical\":\"\",\"religion\":\"\",\"school\":\"\",\"ethnicity\":\"\",\"subs\":\"Male\",\"patrolid\":\"#{member[4]}\",\"patrolleader\":\"0\",\"joined\":\"2006-01-01\",\"age\":\"6 \\/ 0\",\"yrs\":9,\"patrol\":\"\"},"
  end
  body[-1] = ']'
  body += '}'

  FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/#{url}", :body => body)
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

  FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/#{url}", :body => body)
end

Given /^an OSM request to get terms for section (\d+) will have the terms?$/ do |section_id, table|
  url = "api.php?action=getTerms"

  terms = Array.new
  table.hashes.each do |hash|
     terms.push [hash['term_id'], hash['name']]
  end

  body = '{"' + section_id + '":['
  terms.each do |term|
    body += "{\"termid\":\"#{term[0]}\",\"name\":\"#{term[1]}\",\"sectionid\":\"#{section_id}\",\"startdate\":\"#{1.month.ago.to_date.to_s('yyyy-mm-dd')}\",\"enddate\":\"#{1.month.from_now.to_date.to_s('yyyy-mm-dd')}\"},"
  end
  body[-1] = ']'
  body += '}'

  FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/#{url}", :body => body)
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
  return nil
end

def get_osm_body(description)
  return '{"secret":"abc123","userid":"1234"}' if description.eql?('authorize')
  return nil
end