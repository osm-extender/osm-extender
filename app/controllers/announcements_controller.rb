class AnnouncementsController < ApplicationController
  load_and_authorize_resource

  def index
    @announcements = Announcement.all
    @announcement = Announcement.new(:start => Time.now, :finish => 1.week.from_now.to_date)
  end

  def show
    @announcement = Announcement.find(params[:id])
  end

  def new
    @announcement = Announcement.new(:start => Time.now, :finish => 1.week.from_now.to_date)
  end

  def edit
    @announcement = Announcement.find(params[:id])
  end

  def create
    @announcement = Announcement.new(params[:announcement])

    if @announcement.save
      email_to_users if params[:email_to_users]
      redirect_to announcements_path, notice: 'Announcement was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    @announcement = Announcement.find(params[:id])

    if @announcement.update_attributes(params[:announcement])
      email_to_users if params[:email_to_users]
      redirect_to announcements_path, notice: 'Announcement was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @announcement = Announcement.find(params[:id])
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
