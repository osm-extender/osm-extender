class StaticController < ApplicationController
  skip_before_filter :require_login, :only => [:welcome]
  before_filter :require_connected_to_osm, :only => [:osm_permissions]


  def welcome
  end


  def my_page
    if current_user.connected_to_osm?
      @roles = current_user.osm_api.get_roles[:data]

      @tasks = []
      @tasks.push({:name=>'Administer users', :path=>users_path}) if can?(:administer, User)
      @tasks.push({:name=>'Administer FAQs', :path=>faqs_path}) if can?(:administer, Faq)

    else
      flash[:instruction] = "You need to connect your account to your OSM account. #{self.class.helpers.link_to 'Connect now.', connect_to_osm_path}".html_safe
      @roles = []
    end
  end


  def osm_permissions
    @osmx_permissions = current_user.osm_api.get_our_api_access(current_section.id, {:no_cache => true})[:data]
  end

end
