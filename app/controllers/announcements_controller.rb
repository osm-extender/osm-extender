class AnnouncementsController < ApplicationController
  load_and_authorize_resource :except=>[:new, :create]
  authorize_resource :only=>[:new, :create]

  before_action :only=>[:index, :new] do
    now = Time.zone.now
    now_hr = now.strftime('%H')
    now_min = now.strftime('%M').to_i
    @announcement = Announcement.new(
      :start => DateTime.parse(now_hr + ':' + (now_min - (now_min % 5)).to_s) - 5.minutes,
      :finish => 8.days.from_now.to_date
    )
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

    if @announcement.invalid?
      render action: :new, status: 422
    elsif @announcement.save
      email_to_users if params[:email_to_users]
      redirect_to announcements_path, notice: 'Announcement was successfully created.'
    else
      render action: :new, status: 500, error: 'Announcement could not be created.'
    end
  end

  def update
    @announcement.assign_attributes(sanatised_params.announcement)

    if @announcement.invalid?
      render action: :edit, status: 422
    elsif @announcement.save
      email_to_users if params[:email_to_users]
      redirect_to announcements_path, notice: 'Announcement was successfully updated.'
    else
      render action: :edit, status: 500, error: 'Announcement could not be updated.'
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
