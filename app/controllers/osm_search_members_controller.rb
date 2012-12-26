class OsmSearchMembersController < ApplicationController
  before_filter :require_connected_to_osm
  before_filter { require_osm_permission :read, :member }

  def search_form
    @column_names = {}
    @field_keys = []
    Osm::Section.get_all(current_user.osm_api).each do |section|
      if api_has_osm_permission?(:read, :member, current_user, section) && user_has_osm_permission?(:read, :member, current_user, section)
        @column_names[section.id] = {:first_name=>'First name', :last_name=>'Last name'}.merge(section.column_names)
        @field_keys |= section.column_names.keys
      end
    end
    @section_ids = @column_names.keys
  end

  def search_results
    search_for = params[:search_for].downcase
    @found = {}
    params[:selected].keys.map{|i| i.to_i}.each do |section_id|
      # Get columns to search for this section
      columns = [:first_name, :last_name]
      Osm::Section.get(current_user.osm_api, section_id).column_names.keys.each do |key|
        columns.push key if params[:selected][section_id.to_s][key.to_s] == '1'
      end

      # Find the members which match
      Osm::Member.get_for_section(current_user.osm_api, section_id).each do |member|
        match = false
        columns.each do |column|
          if member.send(column).downcase.include?(search_for)
            match = true
          end
        end
        if match
          @found[section_id] ||= []
          @found[section_id].push member
        end
      end
    end
  end

end
