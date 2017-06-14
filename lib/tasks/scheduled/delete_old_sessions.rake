namespace :scheduled  do
  desc "Delete old sessions"
  task :delete_old_sessions => :environment do
    $PROGRAM_NAME = "OSMX #{Rails.env} - Delete old sessions"
    deleted = Session.delete_old_sessions.size
    puts "#{ActionController::Base.helpers.pluralize(deleted, 'session')} deleted."
  end
end
