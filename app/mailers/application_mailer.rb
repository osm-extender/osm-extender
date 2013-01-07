class ApplicationMailer < ActionMailer::Base
  layout 'mail'

  EXTRACT_EMAIL_ADDRESS_REGEX = /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i


  private
  def build_subject(subject)
    start = 'OSMExtender'
    start += " (#{Rails.env.upcase})" unless Rails.env.production?
    return "#{start} - #{subject}"
  end

end
