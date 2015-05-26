class MapMembersController < ApplicationController
  before_action :require_connected_to_osm
  before_action :get_section_from_params, :except=>:index
  before_action :except=>:index do
    forbid_section_type :waiting, @section
  end
  before_action :except=>:index do
    require_osm_permission :read, :member, current_user, @section
  end
  before_action do
    @addresses = {'Member' => 'contact', 'Primary contact 1' => 'primary_contact', 'Primary contact 2' => 'secondary_contact', 'Emergency contact' => 'emergency_contact', 'Doctor' => 'doctor'}
  end


  def index
    @sections = Osm::Section.get_all(osm_api).select{ |s| !s.waiting? }
  end

  def page
    @groupings = get_section_groupings(@section)
    @pin_colours = %w{red green blue yellow brown orange purple white grey black}
  end

  def data
    address_method = @addresses.values.include?(params[:address]) ? params[:address] : 'contact'
    members = Array.new
    message = nil

    Osm::Member.get_for_section(osm_api, @section).each do |member|
      contact = member.send(address_method)
      break if contact.nil? # This contact is hidden in OSM so break out of the loop
      address = [contact.address_1, contact.address_2, contact.address_3, contact.address_4, contact.postcode]
      address = address.select{ |i| !i.blank? }.join(', ')
      members.push ({
        :grouping_id => member.grouping_id,
        :name => member.name,
        :address => address,
      })
    end

    render :json => {
      :members => members,
      :groupings => get_section_groupings(@section).invert
    }
    log_usage
  end

end
