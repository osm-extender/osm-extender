class StaticController < ApplicationController
  skip_before_filter :require_login, :only => [:welcome]
  before_filter :require_connected_to_osm, :only => [:osm_permissions]


  def welcome
  end


  def my_page
    if current_user.connected_to_osm?
      roles = current_user.osm_api.get_roles.sort
      @sections = roles.inject([]) do |new_array, role|
        new_array.push ({:id => role.section.id, :name => role.long_name})
        new_array
      end
    else
      @sections = []
      flash[:instruction] = "You need to connect your account to your OSM account. #{self.class.helpers.link_to 'Connect now.', connect_to_osm_path}".html_safe
    end
  end


  def osm_permissions
    @osmx_permissions = Hash.new
    @other_roles = Array.new
    current_user.osm_api.get_roles.each do |role|
      @other_roles.push role unless role == current_role
      @osmx_permissions[role.section.id] = current_user.osm_api.get_our_api_access(role.section, {:no_cache => true})
    end
    @other_roles.sort!
  end

end
