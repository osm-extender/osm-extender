namespace :app  do
  desc "Setup the app for first use"
  task :setup => :environment do
    require 'tty-prompt'
    prompt = TTY::Prompt.new

    if User.none?
      if prompt.yes?("Would you like to create your site's first super user?")
        user = User.new name: `whoami`.chomp
        until user.valid?
          user.name = prompt.ask("What is the user's name?") { |q|
            q.required true
            q.default user.name
            q.validate /\A[A-Za-z '.]+\Z/
            q.modify :trim
          }.titleize
          user.email_address = prompt.ask("What is the user's email address?") { |q|
            q.required true
            q.default user.email_address if user.email_address?
            q.modify :trim
          }
          user.password = SecureRandom.base64(15)[0..10]

          unless user.valid?
            puts "ERRORS:"
            puts user.errors.full_messages.map{ |e| " * #{e}" }
          end
        end # while not valid

        # Set all permissions for user
        User.column_names.select{ |i| i[0..3].eql?('can_') }.each do |p|
          user.send "#{p}=", true
        end

        puts "The user's password is #{user.password}"
        user.skip_activation_needed_email = true
        user.skip_activation_success_email = true
        user.save!
        user.activate!
      end # if create user
    end # if no users in database

  end # setup task

end
