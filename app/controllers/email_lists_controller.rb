class EmailListsController < ApplicationController
  before_action :require_connected_to_osm
  before_action :clean_search_params, :only=>[:new, :create, :update, :preview]
  load_and_authorize_resource :except=>[:new, :create]
  authorize_resource :only=>[:new, :create]


  def index
    @email_lists = current_user.email_lists
    @email_list = EmailList.new(sanatised_params.email_list)
    @email_list.section_id ||= current_section.id
    @section_names = get_section_names
    @groupings = get_all_groupings
    @sections_data = get_sections_data
  end

  def show
    @email_list = current_user.email_lists.find(params[:id])
  end

  def new
    @email_list = current_user.email_lists.new(sanatised_params.email_list.reverse_merge({section_id: current_section.id}))
    @section_names = get_section_names
    @groupings = get_all_groupings
    @sections_data = get_sections_data
  end

  def edit
    @email_list = current_user.email_lists.find(params[:id])
    @groupings = get_all_groupings
    @sections_data = get_sections_data
  end

  def create
    @email_list = current_user.email_lists.new(sanatised_params.email_list)

    if @email_list.invalid?
      @section_names = get_section_names
      @groupings = get_all_groupings
      @sections_data = get_sections_data
      render action: :new, status: 422
    elsif @email_list.save
      redirect_to email_lists_path, notice: 'Email list was successfully created.'
    else
      render action: :new, status: 500, error: 'Email list could not be created.'
    end
  end

  def update
    @email_list = current_user.email_lists.find(params[:id])
    @email_list.assign_attributes(sanatised_params.email_list)

    if @email_list.invalid?
      render action: :edit, status: 422
    elsif @email_list.save
      redirect_to email_lists_path, notice: 'Email list was successfully updated.'
    else
      @groupings = get_all_groupings
      @sections_data = get_sections_data
      render action: :edit, status: 500, error: 'Email list could not be updated.'
    end
  end

  def destroy
    @email_list = current_user.email_lists.find(params[:id])
    @email_list.destroy

    redirect_to email_lists_path
  end


  def preview
    my_params = sanatised_params.email_list
    if my_params.values_at(:contact_member, :contact_primary, :contact_secondary, :contact_emergency).uniq.eql?([0])
      flash[:error] = 'You must select at least one contact to get some addresses for.'
      redirect_to email_lists_path(email_list: my_params) and return
    end

    @groupings = get_all_groupings
    @email_list = current_user.email_lists.new(my_params)
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
        redirect_to email_lists_path
    end
  end


  private
  def clean_search_params
    if params[:email_list].is_a?(Hash)
      params[:email_list][:match_type] = params[:email_list][:match_type].is_a?(String) ? params[:email_list][:match_type].downcase.eql?('true') : false
      params[:email_list][:match_grouping] = params[:email_list][:match_grouping].to_i
      params[:email_list][:contact_member] = params[:email_list][:contact_member].to_i
      params[:email_list][:contact_primary] = params[:email_list][:contact_primary].to_i
      params[:email_list][:contact_secondary] = params[:email_list][:contact_secondary].to_i
      params[:email_list][:contact_emergency] = params[:email_list][:contact_emergency].to_i
    else
      {}
    end
  end

  def clean_lists(lists)
    (lists || {}).select{ |k,v| v['selected'].eql?('1') }.map{ |k,v| k.to_i}
  end

  def get_sections_data
    data = {}
    groupings = get_all_groupings
    Osm::Section.get_all(osm_api).each do |section|
      if has_osm_permission?(:read, :member, current_user, section)
        data[section.id] = {
          'grouping_name' => get_grouping_name(section.type),
          'groupings' => groupings[section.id],
        }
      end
    end
    return data.to_json.gsub('"', '\"').html_safe
  end

  def multiple_get_addresses(lists)
    lists = clean_lists(lists)
    @email_lists = current_user.email_lists.find(lists).sort{ |a, b|
      section_a = Osm::Section.get(osm_api, a.section_id)
      section_b = Osm::Section.get(osm_api, b.section_id)
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

end
