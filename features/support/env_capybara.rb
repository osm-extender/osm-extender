Capybara.app_host = "#{Rails.application.routes.default_url_options[:protocol] || 'http'}://" + 
                    Rails.application.routes.default_url_options[:host]

Capybara.server_port = Rails.application.routes.default_url_options[:port] || 80
