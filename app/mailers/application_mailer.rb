class ApplicationMailer < ActionMailer::Base
  layout 'mail'


  private
  def build_subject(subject)
    start = 'OSMExtender'
    start += " (#{Rails.env.upcase})" unless Rails.env.production?
    return "#{start} - #{subject}"
  end

  def build_url(path)
    return Rails.configuration.root_url.to_s + path
  end

end
