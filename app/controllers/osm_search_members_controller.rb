class OsmSearchMembersController < ApplicationController
  before_action :require_connected_to_osm
  before_action { require_osm_permission :read, :member }
  before_action do
    @columns = {
      'contact' => %w{address_1 address_2 address_3 address_4 postcode phone_1 phone_2 email_1 email_2},
      'primary_contact' => %w{first_name last_name address_1 address_2 address_3 address_4 postcode phone_1 phone_2 email_1 email_2},
      'secondary_contact' => %w{first_name last_name address_1 address_2 address_3 address_4 postcode phone_1 phone_2 email_1 email_2},
      'emergency_contact' => %w{first_name last_name address_1 address_2 address_3 address_4 postcode phone_1 phone_2 email_1 email_2},
      'doctor' => %w{first_name last_name surgery address_1 address_2 address_3 address_4 postcode phone_1 phone_2},
    }
    @column_groups = {
      'contact' => 'Member',
      'primary_contact' => 'Primary Contact 1',
      'secondary_contact' => 'Primary Contact 2',
      'emergency_contact' => 'Emergency',
      'doctor' => "Doctor's Surgery",
    }
    @section_ids = Osm::Section.get_all(osm_api)
    @section_ids.select!{ |section| current_user.has_osm_permission?(section, :read, :member) }
    @section_ids.map!{ |section| section.id }
  end

  def search_form
  end

  def search_results
    if params[:selected].nil?
      flash[:error] = 'You must select some fields to search.'
      redirect_to osm_search_members_form_path(:search_for => params[:search_for]) and return
    end

    search_for = params[:search_for].downcase
    @found = {}
    @found_where = {}
    @section_ids.each do |section_id|
      next unless params[:selected].keys.include?(section_id.to_s)
      Osm::Member.get_for_section(osm_api, section_id).each do |member|
        selected = params[:selected][section_id.to_s]
        @columns.each do |contact, columns|
          (selected[contact] || {}).each do |column, sel|
            next unless @columns[contact].include?(column) # Whitelist the attributes that are allowed to be searched
            next unless sel.eql?('1')
            value = member.try(contact).try(column)
            if !value.nil? && value.downcase.include?(search_for)
              @found[section_id] ||= []
              @found[section_id].push member unless @found[section_id].include?(member)
              @found_where[section_id] ||= {}
              @found_where[section_id][member.id] ||= []
              @found_where[section_id][member.id].push "#{@column_groups[contact]}: #{column.titleize} - \"#{value}\""
            end
          end # each column for contact
        end # each contact for member
      end # each member
    end # each section
    log_usage
  end

end
