class MapMembersController < ApplicationController
  before_action :require_connected_to_osm
  before_action :get_section_from_params, :except=>:index
  before_action :except=>:index do
    forbid_section_type :waiting, @section
  end
  before_action :except=>:index do
    require_osm_permission :read, :member, current_user, @section
  end


  def index
    @sections = Osm::Section.get_all(current_user.osm_api).select{ |s| !s.waiting? }
  end

  def page
    @groupings = get_section_groupings(@section)
    @pin_colours = %w{red green blue yellow brown orange purple white grey black}
  end

  def data
    address_method = ['address', 'address2'].include?(params[:address]) ? params[:address] : 'address'
    members = Array.new

    Osm::Member.get_for_section(current_user.osm_api, @section).each do |member|
      members.push ({
        :grouping_id => member.grouping_id,
        :name => member.name,
        :address => member.send(address_method)
      })
    end

    render :json => {
      :members => members,
      :groupings => get_section_groupings(@section).invert
    }
    log_usage
  end

end
