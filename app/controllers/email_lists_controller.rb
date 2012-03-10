class EmailListsController < ApplicationController
  before_filter :require_connected_to_osm

  def generate
    @section = current_user.osm_api.get_section(session[:current_section_id])
    @column_names = @section.column_names
    @groupings = current_user.osm_api.get_groupings(@section.id)[:data]
  end

  def generate2
    match_type = params[:match_type].eql?('yes')
    match_grouping = params[:match_grouping].to_i
    add_email1 = params[:email1].eql?('1')
    add_email2 = params[:email2].eql?('1')
    add_email3 = params[:email3].eql?('1')
    add_email4 = params[:email4].eql?('1')

    @emails = Array.new
    members = current_user.osm_api.get_members(session[:current_section_id])[:data]
    members.each do |member|
      if ((match_grouping == 0) || (member.grouping_id == match_grouping)) ==  match_type
        @emails.push member.email1 if add_email1 && !@emails.include?(member.email1) && !member.email1.blank?
        @emails.push member.email2 if add_email2 && !@emails.include?(member.email2) && !member.email2.blank?
        @emails.push member.email3 if add_email3 && !@emails.include?(member.email3) && !member.email3.blank?
        @emails.push member.email4 if add_email4 && !@emails.include?(member.email4) && !member.email4.blank?
      end
    end
  end

end
