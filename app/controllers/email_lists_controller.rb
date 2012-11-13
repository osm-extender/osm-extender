class EmailListsController < ApplicationController
  before_filter :require_connected_to_osm
  load_and_authorize_resource

  def index
    @email_lists = current_user.email_lists
    @email_list = EmailList.new(:user => current_user, :section_id => current_section.id)
    @section_names = get_section_names

    @groupings = get_all_groupings
    @sections_data = get_sections_data
  end

  def show
    @email_list = current_user.email_lists.find(params[:id])
  end

  def new
    @email_list = current_user.email_lists.new(:section_id => current_section.id)
    @groupings = get_all_groupings
    @sections_data = get_sections_data
  end

  def edit
    @email_list = current_user.email_lists.find(params[:id])
    @groupings = get_all_groupings
    @sections_data = get_sections_data
  end

  def create
    @email_list = current_user.email_lists.new(clean_params(params[:email_list]))

    if @email_list.save
      redirect_to email_lists_url, notice: 'Email list was successfully saved.'
    else
      @groupings = get_all_groupings
      @sections_data = get_sections_data
      render action: "new"
    end
  end

  def update
    @email_list = current_user.email_lists.find(params[:id])

    if @email_list.update_attributes(clean_params(params[:email_list]))
      redirect_to email_lists_url, notice: 'Email list was successfully updated.'
    else
      @groupings = get_all_groupings
      @sections_data = get_sections_data
      render action: "edit"
    end
  end

  def destroy
    @email_list = current_user.email_lists.find(params[:id])
    @email_list.destroy

    redirect_to email_lists_url
  end


  def preview
    @params = params
    @groupings = get_all_groupings
    @email_list = current_user.email_lists.new(clean_params(params[:email_list]))
    @lists = @email_list.get_list
  end

  def get_addresses
    @email_list = current_user.email_lists.find(params[:id])
    @lists = @email_list.get_list
  end

  def multiple
    case params[:commit]
      when 'Get addresses'
        multiple_get_addresses(params[:email_list])
      else
        flash[:error] = 'That was an invalid action.'
        redirect_to email_lists_url
    end
  end

  def tool
    case params[:commit]
      when 'Find address'
        tool_find_address(params[:find_address])
      else
        flash[:error] = 'That was an invalid tool.'
        redirect_to email_lists_url
    end
  end


  private
  def clean_params(params_in)
    params = params_in.clone
    [:email1, :email2, :email3, :email4, :match_type].each do |key|
      params[key] = params[key].is_a?(String) ? params[key].downcase.eql?('true') : false
    end
    params[:match_grouping] = params[:match_grouping].to_i
    return params
  end
  
  def clean_lists(lists)
    (lists || {}).select{ |k,v| v['selected'].eql?('1') }.map{ |k,v| k.to_i}
  end

  def get_sections_data
    data = {}
    groupings = get_all_groupings
    Osm::Section.get_all(current_user.osm_api).each do |section|
      data[section.id] = {
        'fields' => section.column_names.select{ |k,v| [:email1, :email2, :email3, :email4].include?(k) },
        'grouping_name' => get_grouping_name(section.type),
        'groupings' => groupings[section.id],
      }
    end
    return data.to_json.gsub('"', '\"').html_safe
  end

  def multiple_get_addresses(lists)
    lists = clean_lists(lists)
    @email_lists = current_user.email_lists.find(lists).sort{ |a, b|
      section_a = Osm::Section.get(current_user.osm_api, a.section_id)
      section_b = Osm::Section.get(current_user.osm_api, b.section_id)
      compare = section_a.group_name <=> section_b.group_name
      (compare == 0) ? a.name <=> b.name : compare
    }

    @emails = []
    @no_emails = {}
    @email_lists.each do |list|
      addresses = list.get_list
      addresses[:emails].each do |address|
        @emails.push address unless @emails.include?(address)
      end
      @no_emails[list.id] = addresses[:no_emails]
    end

    @section_names = get_section_names
    render 'multiple_get_addresses'
  end


  def tool_find_address(address)
    address = address.downcase
    @address = address
    @found = []
    Osm::Section.get_all(current_user.osm_api).each do |section|
      unless section.waiting?
        Osm::Member.get_for_section(current_user.osm_api, section.id).each do |member|
          if member.email1.downcase.include?(address) || member.email2.downcase.include?(address) || member.email3.downcase.include?(address) || member.email4.downcase.include?(address)
            @found.push({
              :member_name => member.name,
              :section_name => "#{section.group_name} : #{section.name}",
            })
          end
        end
      end
    end

    @found.sort! do |a,b|
      ret =  a[:member_name] <=> b[:member_name]
      ret = 1 if a[:section_name] > b[:section_name]
      ret = -1 if a[:section_name] < b[:section_name]
      ret
    end
    render 'tool_find_address'
  end

end
