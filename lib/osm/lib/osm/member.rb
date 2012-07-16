module Osm

  class Member

    attr_reader :id, :section_id, :type, :first_name, :last_name, :email1, :email2, :email3, :email4, :phone1, :phone2, :phone3, :phone4, :address, :address2, :date_of_birth, :started, :joined_in_years, :parents, :notes, :medical, :religion, :school, :enthnicity, :subs, :grouping_id, :grouping_leader, :joined, :age, :joined_years, :patrol

    # Initialize a new Member using the hash returned by the API call
    # @param data the hash of data for the object returned by the API
    def initialize(data)
      @id = data['scoutid']
      @section_id = data['sectionid']
      @type = data['type']
      @first_name = data['firstname']
      @last_name = data['lastname']
      @email1 = data['email1']
      @email2 = data['email2']
      @email3 = data['email3']
      @email4 = data['email4']
      @phone1 = data['phone1']
      @phone2 = data['phone2']
      @phone3 = data['phone3']
      @phone4 = data['phone4']
      @address = data['address']
      @address2 = data['address2']
      @date_of_birth = Osm::parse_date(data['dob'])
      @started = data['started']
      @joined_in_years = data['joining_in_yrs']
      @parents = data['parents']
      @notes = data['notes']
      @medical = data['medical']
      @religion = data['religion']
      @school = data['school']
      @ethnicity = data['ethnicity']
      @subs = data['subs']
      @grouping_id = data['patrolid'].to_i
      @grouping_leader = data['patrolleader'] # 0 - No, 1 = seconder, 2 = sixer
      @joined = Osm::parse_date(data['joined'])
      @age = data['age'] # 'yy / mm'
      @joined_years = data['yrs']
      @patrol = data['patrol']
    end

    # Get the years element of this scout's age
    # @returns the number of years this scout has been alive
    def age_years
      return @age[0..1].to_i
    end

    # Get the months element of this scout's age
    # @returns the number of months since this scout's last birthday
    def age_months
      return @age[-2..-1].to_i
    end

    # Get the full name
    # @param seperator (optional) what to split the scout's first name and last name with, defaults to a space
    # @returns this scout's full name seperate by the optional seperator
    def name(seperator=' ')
      return "#{@first_name}#{seperator.to_s}#{@last_name}"
    end

  end

end
