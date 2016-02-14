class MapMembersController < ApplicationController
  before_action :require_connected_to_osm
  before_action :get_section_from_params, :except=>[:index, :multiple_page, :multiple_data]
  before_action :except=>[:index, :multiple_page, :multiple_data] do
    forbid_section_type :waiting, @section
  end
  before_action :except=>[:index, :multiple_page, :multiple_data] do
    require_osm_permission :read, :member, current_user, @section
  end
  before_action do
    @addresses = {'Member' => 'contact', 'Primary contact 1' => 'primary_contact', 'Primary contact 2' => 'secondary_contact', 'Emergency contact' => 'emergency_contact', 'Doctor' => 'doctor'}
    @pin_colours = %w{red green blue yellow brown orange purple white grey black}
  end


  def index
    @sections = Osm::Section.get_all(osm_api).select{ |s| !s.waiting? }
  end

  def page
    @groupings = get_section_groupings(@section)
  end

  def data
    members = get_address_data_for_section(@section)

    render :json => {
      members: members,
    }
    log_usage
  end


  def multiple_page
    @sections = Osm::Section.get_all(osm_api).select{ |s| !s.waiting? }
  end

  def multiple_data
    params['include'] ||= {}
    sections = Osm::Section.get_all(osm_api)
    sections.select!{ |s| !s.waiting? }
    sections.select!{ |s| params['include'][s.id.to_s].eql?('1') }

    members = []
    errors = []
    sections.each do |section|
      begin
        members += get_address_data_for_section(section)
      rescue Osm::Error::NoCurrentTerm
        errors.push "No current term for section  -  #{get_section_names[section.id]}"
      end
    end

    render :json => {
      members: members,
      errors: errors,
    }
    log_usage
  end


  private
  def get_address_data_for_section(section)
    address_method = @addresses.values.include?(params[:address]) ? params[:address] : 'contact'
    members = Array.new
    groupings = get_section_groupings(section).invert

    Osm::Member.get_for_section(osm_api, section).each do |member|
      contact = member.send(address_method)
      break if contact.nil? # This contact is hidden in OSM so break out of the loop
      address = [contact.address_1, contact.address_2, contact.address_3, contact.address_4, contact.postcode]
      address = address.select{ |i| !i.blank? }.join(', ')
      members.push ({
        section_id: member.section_id,
        section_name: get_section_names[member.section_id],
        grouping_id: member.grouping_id,
        grouping_name: groupings[member.grouping_id],
        name: member.name,
        address: address,
      })
    end

    return members
  end

end
