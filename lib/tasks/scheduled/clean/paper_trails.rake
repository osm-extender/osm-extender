namespace :scheduled  do
  namespace :clean  do
    desc "Stop the versions tables getting too big"
    task :paper_trails => :environment do
      $PROGRAM_NAME = "OSMX #{Rails.env} - Clean Paper Trails"
      deleted = 0
      [PaperTrail::Version, UserVersion].each do |model|
        this_deleted = model.destroy_all(["created_at < ?", 1.year.ago]).size
        puts "#{this_deleted} old #{model.name} deleted."
        deleted += this_deleted
      end
      puts "#{deleted} total old versions deleted."
    end
  end
end
