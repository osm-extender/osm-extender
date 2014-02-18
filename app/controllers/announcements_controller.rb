class AnnouncementsController < ApplicationController
#  before_action do
#    model = Announcement
#    instance_variable_name = params[:controller].sub("Controller", "").underscore.split('/').last.singularize
#    find_by_attribute = :id
#    find_by_param = find_by_attribute
#
#    instance = model.find(find_by_attribute => params[find_by_param])
#    instance_variable_set("@#{instance_variable_name}", instance)
#    authorize! params[:action].to_sym, (params[:id].nil? ? model : instance)
#  end
  load_and_authorize_resource :except=>[:new, :create]
  authorize_resource :only=>[:new, :create]
  before_action :only=>[:index, :new] do
    @announcement = Announcement.new(:start => Time.now, :finish => 1.week.from_now.to_date)
  end


  def index
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
    @announcement = Announcement.new(sanatised_params.announcement)

    if @announcement.save
      email_to_users if params[:email_to_users]
      redirect_to announcements_path, notice: 'Announcement was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    if @announcement.update(sanatised_params.announcement)
      email_to_users if params[:email_to_users]
      redirect_to announcements_path, notice: 'Announcement was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @announcement.destroy

    redirect_to announcements_path
  end

  def hide
    request.format = :js if params[:format].nil?
    @announcement = current_user.current_announcements.are_hideable.find(params[:id])

    unless @announcement.nil?
      hidden_announcement = current_user.hidden_announcements.new(:announcement => @announcement)
      unless hidden_announcement.save
        @error = "An error occured whilst hiding that announcement."
      end
    else
      @error = "You can't hide that announcement.".html_safe
    end
  end


  private
  def email_to_users
    @announcement.emailed_announcements.delete_all            # Clear list of whoose had it since we're resending it
    Announcement.delay.email_announcement(@announcement.id)   # Setup job to resend it
    flash[:information] = 'Emailing the announcement has been added to the job queue.'
  end

end
