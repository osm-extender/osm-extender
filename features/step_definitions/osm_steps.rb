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
    body += '{"sectionConfig":"{\"subscription_level\":3,\"subscription_expires\":\"2013-01-05\",\"sectionType\":\"cubs\",\"columnNames\":{\"phone1\":\"Home Phone\",\"phone2\":\"Parent 1 Phone\",\"address\":\"Member\'s Address\",\"phone3\":\"Parent 2 Phone\",\"address2\":\"Address 2\",\"phone4\":\"Alternate Contact Phone\",\"subs\":\"Gender\",\"email1\":\"Parent 1 Email\",\"medical\":\"Medical / Dietary\",\"email2\":\"Parent 2 Email\",\"ethnicity\":\"Gift Aid\",\"email3\":\"Member\'s Email\",\"religion\":\"Religion\",\"email4\":\"Email 4\",\"school\":\"School\"},\"numscouts\":10,\"hasUsedBadgeRecords\":true,\"hasProgramme\":true,\"extraRecords\":[{\"name\":\"Subs\",\"extraid\":\"529\"}],\"wizard\":\"false\",\"fields\":{\"email1\":true,\"email2\":true,\"email3\":true,\"email4\":false,\"address\":true,\"address2\":false,\"phone1\":true,\"phone2\":true,\"phone3\":true,\"phone4\":true,\"school\":false,\"religion\":true,\"ethnicity\":true,\"medical\":true,\"patrol\":true,\"subs\":true,\"saved\":true},\"intouch\":{\"address\":true,\"address2\":false,\"email1\":false,\"email2\":false,\"email3\":false,\"email4\":false,\"phone1\":true,\"phone2\":true,\"phone3\":true,\"phone4\":true,\"medical\":false},\"mobFields\":{\"email1\":false,\"email2\":false,\"email3\":false,\"email4\":false,\"address\":true,\"address2\":false,\"phone1\":true,\"phone2\":true,\"phone3\":true,\"phone4\":true,\"school\":false,\"religion\":false,\"ethnicity\":true,\"medical\":true,\"patrol\":true,\"subs\":false}}","groupname":"1st Somewhere","groupid":"1","groupNormalised":"1","sectionid":"' + role.to_s + '","sectionname":"Section ' + role.to_s + '","section":"cubs","isDefault":"1","permissions":{"badge":100,"member":100,"user":100,"register":100,"contact":100,"programme":100,"originator":1,"events":100,"finance":100,"flexi":100}},'
#    body += '{"sectionConfig":{"subscription_level":3,"subscription_expires":"2013-01-05","sectionType":"cubs","columnNames":{"phone1":"Home Phone","phone2":"Parent 1 Phone","address":"Member\'s Address","phone3":"Parent 2 Phone","address2":"Address 2","phone4":"Alternate Contact Phone","subs":"Gender","email1":"Parent 1 Email","medical":"Medical / Dietary","email2":"Parent 2 Email","ethnicity":"Gift Aid","email3":"Member\'s Email","religion":"Religion","email4":"Email 4","school":"School"},"numscouts":10,"hasUsedBadgeRecords":true,"hasProgramme":true,"extraRecords":[{"name":"Subs","extraid":"529"}],"wizard":"false","fields":{"email1":true,"email2":true,"email3":true,"email4":false,"address":true,"address2":false,"phone1":true,"phone2":true,"phone3":true,"phone4":true,"school":false,"religion":true,"ethnicity":true,"medical":true,"patrol":true,"subs":true,"saved":true},"intouch":{"address":true,"address2":false,"email1":false,"email2":false,"email3":false,"email4":false,"phone1":true,"phone2":true,"phone3":true,"phone4":true,"medical":false},"mobFields":{"email1":false,"email2":false,"email3":false,"email4":false,"address":true,"address2":false,"phone1":true,"phone2":true,"phone3":true,"phone4":true,"school":false,"religion":false,"ethnicity":true,"medical":true,"patrol":true,"subs":false}},"groupname":"1st Somewhere","groupid":"1","groupNormalised":"1","sectionid":"' + role.to_s + '","sectionname":"Section ' + role.to_s + '","section":"cubs","isDefault":"1","permissions":{"badge":100,"member":100,"user":100,"register":100,"contact":100,"programme":100,"originator":1,"events":100,"finance":100,"flexi":100}},'
  end
  body[-1] = ']'
  url = get_osm_url(description)
  FakeWeb.register_uri(:post, "https://www.onlinescoutmanager.co.uk/#{url}", :body => body) unless url.nil?
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
  return nil
end

def get_osm_body(description)
  return '{"secret":"abc123","userid":"1234"}' if description.eql?('authorize')
  return nil
end