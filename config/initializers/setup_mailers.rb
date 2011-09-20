require File.join(Rails.root, 'lib', 'development_mail_interceptor')

machine_configuration = YAML.load(IO.read(File.join(Rails.root, 'config', 'machine.yml')))

ActionMailer::Base.smtp_settings = {
  :address              => machine_configuration['mailer_server'],
  :port                 => machine_configuration['mailer_port'] || 25,
  :domain               => machine_configuration['mailer_domain'],
  :user_name            => machine_configuration['mailer_username'],
  :password             => machine_configuration['mailer_password'],
  :authentication       => machine_configuration['mailer_authenticaion'] || 'plain',
  :enable_starttls_auto => true
}

ActionMailer::Base.default_url_options[:host] = 'localhost:3000'
ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?