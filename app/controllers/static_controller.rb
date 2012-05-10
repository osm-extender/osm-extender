class StaticController < ApplicationController
  skip_before_filter :require_login, :only => [:welcome]
  before_filter :require_connected_to_osm, :only => [:osm_permissions]


  def welcome
  end


  def my_page
    if current_user.connected_to_osm?
      @roles = current_user.osm_api.get_roles[:data]
    else
      @roles = []
      flash[:instruction] = "You need to connect your account to your OSM account. #{self.class.helpers.link_to 'Connect now.', connect_to_osm_path}".html_safe
    end

    @tasks = []
    @tasks.push({:name=>'Administer users', :path=>users_path}) if can?(:administer, User)
    @tasks.push({:name=>'Administer FAQs', :path=>faqs_path}) if can?(:administer, Faq)
    @tasks.push({:name=>'Administer settings', :path=>edit_settings_path}) if can?(:update, Settings)
    @tasks.push({:name=>'User statistics', :path=>user_statistics_path}) if can?(:administer, User)
    @tasks.push({:name=>'Reminder email statistics', :path=>email_reminders_statistics_path}) if can?(:administer, User)
  end


  def osm_permissions
    @osmx_permissions = Hash.new
    @other_roles = Array.new
    current_user.osm_api.get_roles[:data].each do |role|
      @other_roles.push role unless role == current_role
      @osmx_permissions[role.section.id] = current_user.osm_api.get_our_api_access(role.section.id, {:no_cache => true})[:data]
    end
    @other_roles.sort!
  end

end
