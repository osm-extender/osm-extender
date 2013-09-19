class StaticController < ApplicationController
  skip_before_filter :require_login, :only => [:welcome, :help]
  before_filter :require_connected_to_osm, :only => [:check_osm_setup]


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


  def check_osm_setup
    api = current_user.osm_api
    sections = Osm::Section.get_all(api, :no_cache => true)

    Osm::Model.cache_delete(api, ['permissions', api.user_id]) # Clear cached user permissions
    @other_sections = Array.new
    sections.each do |section|
      Osm::Model.cache_delete(api, ['api_access', api.user_id, section.id]) # Clear cached API permissions
      unless section == current_section
        @other_sections.push section
      else
        set_current_section = section # Make sure current_section has the latest config from OSM
      end
    end
    @other_sections.sort!

    Osm::Term.get_all(api, :no_cache => true) # Load into cache
    @term_problems = {}
    sections.each do |section|
      next if section.waiting?
      @term_problems[section.id] = []
      terms = Osm::Term.get_for_section(api, section).sort
      @term_problems[section.id].push "Has no terms." if terms.empty?
      terms[0..-2].each_with_index do |a, b|
        b = terms[b + 1]
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
