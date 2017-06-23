namespace :scheduled  do
  namespace :clean  do
    desc "Stop the announcements tables getting too big"
    task :announcements => :environment do
      $PROGRAM_NAME = "OSMX #{Rails.env} - Clean Announcements"
      deleted = Announcement.delete_old.size
      puts "#{deleted} announcements deleted."
    end
  end
end
