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
    @email_list = current_user.email_lists.new(clean_params(params[:email_list]).merge({:section_id=>current_section.id}))

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
    @email_list = current_user.email_lists.new(clean_params(params[:email_list]).merge({:section_id=>current_section.id}))
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


  private
  def clean_params(params_in)
    params = params_in.clone
    [:email1, :email2, :email3, :email4, :match_type].each do |key|
      params[key] = params[key].is_a?(String) ? params[key].downcase.eql?('true') : false
    end
    params[:match_grouping] = params[:match_grouping].to_i
    return params
  end

  def get_sections_data
    data = {}
    groupings = get_all_groupings
    current_user.osm_api.get_roles.each do |role|
      data[role.section.id] = {
        'fields' => role.section.column_names.select{ |k,v| [:email1, :email2, :email3, :email4].include?(k) },
        'grouping_name' => get_grouping_name(role.section.type),
        'groupings' => groupings[role.section.id],
      }
    end
    return data.to_json.gsub('"', '\"').html_safe
  end

  def multiple_get_addresses(lists)
    lists = (lists || {}).select{ |k,v| v['selected'].eql?('1') }.map{ |k,v| k.to_i}
    @email_lists = current_user.email_lists.find(lists).sort{ |a, b|
      section_a = current_user.osm_api.get_section(a.section_id)
      section_b = current_user.osm_api.get_section(b.section_id)
      compare = section_a.role <=> section_b.role
      (compare == 0) ? a.name <=> b.name : compare
    }

    @emails = []
    @email_lists.each do |list|
      addresses = list.get_list
      addresses[:emails].each do |address|
        @emails.push address unless @emails.include?(address)
      end
    end

    @section_names = get_section_names
    render 'multiple_get_addresses'
  end

end
