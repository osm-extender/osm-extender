class StaticController < ApplicationController
  skip_before_filter :require_login, :only => [:welcome, :help]
  before_filter :require_connected_to_osm, :only => [:osm_permissions]


  def welcome
  end

  def help
  end

  def my_page
    if current_user.connected_to_osm?
      @sections = Osm::Section.get_all(current_user.osm_api).sort.map do |section|
        {:id => section.id, :name => "#{section.group_name} : #{section.name}"}
      end
    else
      @sections = []
      flash[:instruction] = "You need to connect your account to your OSM account. #{self.class.helpers.link_to 'Connect now.', connect_to_osm_path}".html_safe
    end
  end


  def osm_permissions
    api = current_user.osm_api
    Osm::Model.cache_delete(api, ['permissions', api.user_id]) # Clear cached user permissions

    @other_sections = Array.new
    Osm::Section.get_all(api, :no_cache => true).each do |section|
      unless section == current_section
        @other_sections.push section
      else
        set_current_section = section # Make sure current_section has the latest config from OSM
      end
    end
    @other_sections.sort!
  end

end
