class StaticController < ApplicationController
  skip_before_action :require_login, :only => [:welcome, :help]
  before_action :require_connected_to_osm, :only => [:check_osm_setup]


  def welcome
  end

  def help
  end

  def my_page
    if current_user.connected_to_osm?
      @sections = Osm::Section.get_all(osm_api).sort.map do |section|
        {:id => section.id, :name => "#{section.group_name} : #{section.name}"}
      end
    else
      @sections = []
      flash[:instruction] = "You need to connect your account to your OSM account. #{self.class.helpers.link_to 'Connect now.', connect_to_osm_path}".html_safe
    end
  end


  def check_osm_setup
    sections = Osm::Section.get_all(osm_api, :no_cache => true)

    Osm::Model.cache_delete(osm_api, ['permissions', osm_api.user_id]) # Clear cached user permissions
    @other_sections = Array.new
    sections.each do |section|
      Osm::Model.cache_delete(osm_api, ['api_access', osm_api.user_id, section.id]) # Clear cached API permissions
      unless section == current_section
        @other_sections.push section
      else
        set_current_section = section # Make sure current_section has the latest config from OSM
      end
    end
    @other_sections.sort!

    Osm::Term.get_all(osm_api, :no_cache => true) # Load into cache
    @term_problems = {}
    sections.each do |section|
      next if section.waiting?
      @term_problems[section.id] = []
      terms = Osm::Term.get_for_section(osm_api, section).sort
      @term_problems[section.id].push "Has no terms." if terms.empty?
      terms.each_cons(2) do |a, b|
        if (a.finish + 1.day) < b.start
          # FOUND A GAP
          size = (b.start - a.finish).numerator
          @term_problems[section.id].push "There is a gap of #{size} #{'day'.pluralize(size)} between #{a.name} and #{b.name}."
        end
        if b.start < a.finish
          # FOUND AN OVERLAP
          size = (a.finish - b.start).numerator
          @term_problems[section.id].push "#{b.name} overlaps #{a.name} by #{size} #{'day'.pluralize(size)}."
        end
      end
    end
  end

end
