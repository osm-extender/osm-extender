namespace :app do
  namespace :deploy do
    desc "Wait for migrations to be applied (by another process)"
    task :wait_for_migrations => :environment do
      # Wait for a total of 15½ minutes for migrations to be applied
      intervals = [30, 60, 120, 240, 480]
      applied = false

      if ActiveRecord::Migrator.needs_migration?
        Rails.logger.info 'Waiting for migrations to be applied'
        intervals.each do |interval|
          Rails.logger.debug "Waiting for #{interval}s before rechecking."
          Kernel.sleep interval
          applied = !ActiveRecord::Migrator.needs_migration?
          break if applied
        end # interval in intervals
        fail ActiveRecord::PendingMigrationError unless applied

      else
        Rails.logger.info 'No migrations to be apllied.'
      end
    end # task wait_for_migrations
  end # namespace deploy
end # namespace app
