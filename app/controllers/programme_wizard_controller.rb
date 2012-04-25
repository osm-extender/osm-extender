class ProgrammeWizardController < ApplicationController
  before_filter :require_connected_to_osm
  before_filter { require_osm_permission :write, :programme }

  def new_programme
    @programme = ProgrammeCreate.new
  end

  def create_programme
    @programme = ProgrammeCreate.new(params[:programme_create].merge({:user=>current_user, :section=>current_section}))

    if @programme.valid?
      created = @programme.create_programme
      flash[:notice] = 'Your programme was created.' if created
      flash[:error] = 'Your programme was not completly created.' if !created
      redirect_back_or_to root_url
    else
      params[:action] = 'new_programme'
      render 'new_programme'
    end
  end

end