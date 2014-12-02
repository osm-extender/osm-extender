class ApplicationMailer < ActionMailer::Base
  layout 'mail'
  helper ApplicationHelper
  helper_method :routes

  def routes
    Rails.application.routes.url_helpers
  end

  private
  def build_subject(subject)
    start = 'OSMExtender'
    start += " (#{Rails.env.upcase})" unless Rails.env.production?
    return "#{start} - #{subject}"
  end

end
