module Osm

  class Role

    attr_reader :section, :group_name, :group_id, :group_normalized, :default, :permissions

    # Initialize a new UserRole using the hash returned by the API call
    # @param data the hash of data for the object returned by the API
    def initialize(data)
      @section = Osm::Section.new(data['sectionid'], data['sectionname'], ActiveSupport::JSON.decode(data['sectionConfig']), self)
      @group_name = data['groupname']
      @group_id = Osm::to_i_or_nil(data['groupid'])
      @group_normalized = Osm::to_i_or_nil(data['groupNormalised'])
      @default = data['isDefault'].eql?('1') ? true : false
      @permissions = (data['permissions'] || {}).symbolize_keys

      # Convert permission values to a number
      @permissions.each_key do |key|
        @permissions[key] = @permissions[key].to_i
      end
    end

    # Determine if this role has read access for the provided permission
    # @param key - the key for the permission being queried
    # @returns - true if this role can read the passed permission, false otherwise
    def can_read?(key)
      return [10, 20, 100].include?(@permissions[key])
    end

    # Determine if this role has write access for the provided permission
    # @param key - the key for the permission being queried
    # @returns - true if this role can write the passed permission, false otherwise
    def can_write?(key)
      return [20, 100].include?(@permissions[key])
    end

    # Get section's full name in a consistent format
    # @returns a string e.g. "Scouts (1st Somewhere)"
    def long_name
      @group_name.blank? ? @section.name : "#{@section.name} (#{@group_name})"
    end

    # Get section's full name in a consistent format
    # @returns a string e.g. "1st Somewhere Beavers"
    def full_name
      @group_name.blank? ? @section.name : "#{@group_name} #{@section.name}"
    end

    def <=>(another_role)
      compare_group_name = self.group_name <=> another_role.group_name
      return compare_group_name unless compare_group_name == 0

      return 0 if self.section.type == another_role.section.type
      [:beavers, :cubs, :scouts, :explorers, :waiting, :adults].each do |type|
        return -1 if self.section.type == type
        return 1 if another_role.section.type == type
      end
    end

    def ==(another_role)
      self.section == another_role.try(:section)
    end

  end

end
