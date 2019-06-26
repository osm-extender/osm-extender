class StaticController < ApplicationController
  skip_before_action :require_login, :only => [:welcome, :help, :privacy_policy, :cookie_policy]
  skip_before_action :require_gdpr_consent, :only => [:welcome, :help, :privacy_policy, :cookie_policy]
  before_action :require_connected_to_osm, :only => [:check_osm_setup]

  def privacy_policy
  end

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

  def closing
    email_reminders = current_user.email_reminders.map do |reminder|
      hash = reminder.slice :section_id, :send_on, :section_name
      hash[:items] = reminder.items.order(:position).map do |item|
        item.slice(:type, :configuration)
            .merge(type_name: item.human_name)
      end
      hash[:shares] = reminder.shares.map do |share|
        share.slice :name, :email_address, :state
      end
      hash
    end

    email_lists = current_user.email_lists.map do |list|
      list.slice :section_id, :name, :match_type, :match_grouping,
                 :contact_member, :contact_primary, :contact_secondary, :contact_emergency,
                 :notify_changed, :last_hash_of_addresses
    end

    automation_tasks = current_user.automation_tasks.map do |task|
      task.slice(:section_id, :section_name, :type, :configuration).merge(type_name: task.human_name)
    end

    @email_reminders = {
      osm_user_id: current_user.osm_userid,
      email_reminders: email_reminders
    }
    @email_lists = {
      osm_user_id: current_user.osm_userid,
      email_lists: email_lists
    }
    @automation_tasks = {
      osm_user_id: current_user.osm_userid,
      automation_tasks: automation_tasks
    }
    @everything = {
      name: current_user.name,
      email: current_user.email_address,
      osm_user_id: current_user.osm_userid,
      startup_section: current_user.startup_section,
      email_reminders: email_reminders,
      email_lists: email_lists,
      automation_tasks: automation_tasks,
    }
  end

  def closing_start_updates
    current_user.update closing_updates: true
    redirect_to closing_path, notice: 'You will now receive update emails.'
  end

  def closing_stop_updates
    current_user.update closing_updates: false
    redirect_to closing_path, notice: 'You will now not receive update emails.'
  end
end
