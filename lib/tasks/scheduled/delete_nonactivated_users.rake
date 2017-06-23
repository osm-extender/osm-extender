namespace :scheduled  do
  desc "Remove nonactivated users whose activation tokens have expired"
  task :delete_nonactivated_users => :environment do
    $PROGRAM_NAME = "OSMX #{Rails.env} - Removing nonactivated users"
    deleted = User.activation_expired.destroy_all.size
    puts "#{ActionController::Base.helpers.pluralize(deleted, 'user')} deleted"
  end
end
