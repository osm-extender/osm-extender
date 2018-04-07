namespace :scheduled  do
  namespace :clean  do
    desc "Stop the versions tables getting too big"
    task :paper_trails => :environment do
      $PROGRAM_NAME = "OSMX #{Rails.env} - Clean Paper Trails"
      deleted = PaperTrail::Version.destroy_all(["created_at < ?", 3.months.ago]).size
      puts "#{deleted} old versions deleted."
    end
  end
end
