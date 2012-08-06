class EmailListsController < ApplicationController
  before_filter { forbid_section_type :waiting }
  before_filter :require_connected_to_osm
  before_filter { require_osm_permission :read, :member }
  load_and_authorize_resource

  def index
    @email_lists = current_user.email_lists.where(['section_id = ?', current_section.id])
    @email_list = current_user.email_lists.new
    @groupings = get_groupings
  end

  def show
    @email_list = current_user.email_lists.find(params[:id])
  end

  def new
    @email_list = current_user.email_lists.new(:section_id => current_section.id)
    @groupings = get_groupings
  end

  def edit
    @email_list = current_user.email_lists.find(params[:id])
    @groupings = get_groupings
  end

  def create
    @email_list = current_user.email_lists.new(clean_params(params[:email_list]).merge({:section_id=>current_section.id}))

    if @email_list.save
      redirect_to email_lists_url, notice: 'Email list was successfully saved.'
    else
      @groupings = get_groupings
      render action: "new"
    end
  end

  def update
    @email_list = current_user.email_lists.find(params[:id])

    if @email_list.update_attributes(clean_params(params[:email_list]))
      redirect_to email_lists_url, notice: 'Email list was successfully updated.'
    else
      @groupings = get_groupings
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
    @groupings = get_groupings
    @email_list = current_user.email_lists.new(clean_params(params[:email_list]).merge({:section_id=>current_section.id}))
    @lists = @email_list.get_list
  end

  def get_addresses
    @email_list = current_user.email_lists.find(params[:id])
    @lists = @email_list.get_list
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

end
