class EmailListsController < ApplicationController
  before_filter :require_connected_to_osm
  before_filter { require_osm_permission :read, :member }
  load_and_authorize_resource

  # GET /email_lists
  # GET /email_lists.json
  def index
    @email_lists = current_user.email_lists.where(['section_id = ?', current_section.id])
    @email_list = current_user.email_lists.new
    @groupings = get_groupings

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @email_lists }
    end
  end

  # GET /email_lists/1
  # GET /email_lists/1.json
  def show
    @email_list = current_user.email_lists.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @email_list }
    end
  end

  # GET /email_lists/new
  # GET /email_lists/new.json
  def new
    @email_list = current_user.email_lists.new(:section_id => current_section.id)
    @groupings = get_groupings

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @email_list }
    end
  end

  # GET /email_lists/1/edit
  def edit
    @email_list = current_user.email_lists.find(params[:id])
    @groupings = get_groupings
  end

  # POST /email_lists
  # POST /email_lists.json
  def create
    @email_list = current_user.email_lists.new(clean_params(params[:email_list]).merge({:section_id=>current_section.id}))

    respond_to do |format|
      if @email_list.save
        format.html { redirect_to email_lists_url, notice: 'Email list was successfully saved.' }
        format.json { render json: @email_list, status: :created, location: @email_list }
      else
        @groupings = get_groupings
        format.html { render action: "new" }
        format.json { render json: @email_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /email_lists/1
  # PUT /email_lists/1.json
  def update
    @email_list = current_user.email_lists.find(params[:id])

    respond_to do |format|
      if @email_list.update_attributes(clean_params(params[:email_list]))
        format.html { redirect_to email_lists_url, notice: 'Email list was successfully updated.' }
        format.json { head :ok }
      else
        @groupings = get_groupings
        format.html { render action: "edit" }
        format.json { render json: @email_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /email_lists/1
  # DELETE /email_lists/1.json
  def destroy
    @email_list = current_user.email_lists.find(params[:id])
    @email_list.destroy

    respond_to do |format|
      format.html { redirect_to email_lists_url }
      format.json { head :ok }
    end
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
      params[key] = params[key].downcase.eql?('true')
    end
    params[:match_grouping] = params[:match_grouping].to_i
    return params
  end

  def get_groupings
    groupings = {}
    current_user.osm_api.get_groupings(current_section.id)[:data].each do |grouping|
      groupings[grouping.name] = grouping.id
    end
    return groupings
  end

end
