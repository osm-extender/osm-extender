PremailerRails.config.merge!(
  :adapter => :nokogiri,
  :base_url =>  !Rails.configuration.action_mailer.default_url_options.nil? ? ((Rails.configuration.action_mailer.default_url_options[:protocol] ? "#{Rails.configuration.action_mailer.default_url_options[:protocol]}://" : '') +
                Rails.configuration.action_mailer.default_url_options[:host] +
                (Rails.configuration.action_mailer.default_url_options[:port] ? ":#{Rails.configuration.action_mailer.default_url_options[:port]}" : '') +
                '/') : '/',
  :generate_text_part => true,
)
