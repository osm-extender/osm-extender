class MapMembersController < ApplicationController
  before_filter { forbid_section_type :waiting }
  before_filter :require_connected_to_osm
  before_filter { require_osm_permission :read, :member }


  def page
    @groupings = get_current_section_groupings
    @pin_colours = %w{Red Green Blue Yellow Brown Orange Purple White Grey Black}
  end

  def data
    address_method = ['address', 'address2'].include?(params[:address]) ? params[:address] : 'address'
    members = Array.new

    Osm::Member.get_for_section(current_user.osm_api, current_section).each do |member|
      members.push ({
        :grouping_id => member.grouping_id,
        :name => member.name,
        :address => member.send(address_method)
      })
    end

    render :json => {
      :members => members,
      :groupings => get_current_section_groupings.invert
    }
  end

end
