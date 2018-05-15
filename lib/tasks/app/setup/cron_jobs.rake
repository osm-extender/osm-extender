namespace :app do
  namespace :setup do
    desc "Setup the app's cron jobs"
    task :cron_jobs => :environment do

      # (sec) min hour day month day_of_week
      cron_jobs = {
        # daily (at 3AM)
        '0 3 * * *' => [
          AutomationTasksJob,
          CreateStatisticsJob,
          EmailListsJob,
          PruneUnactivatedUsersJob,
          ReminderEmailsJob,
        ],
        # monthly (at 1AM on 1st)
        '0 1 1 * *' => [
          PruneAnnouncementsJob,
          PruneBalancedProgrammeCacheJob,
          PrunePaperTrailsJob,
        ],
      }

      existing_jobs = Delayed::Job.where.not(cron: nil).pluck(:handler).map{ |h| YAML.load(h).class }
      puts 'Adding cron jobs'
      cron_jobs.each do |cron_exp, jobs|
        next_time = DelayedCronJob::Cronline.new(cron_exp).next_time
        puts "\t#{cron_exp}\t#{next_time}"
        jobs.each do |job|
          print "\t\t#{job} - "
          if existing_jobs.include?(job)
            puts 'already exists - not adding another'
          else
            puts 'not found - adding'
            #Delayed::Job.enqueue job.new, cron: cron_exp, run_at: next_time
            Delayed::Job.create(
              handler: job.new.to_yaml,
              cron: cron_exp,
              run_at: 1.minute.from_now, # Stops the job running right now - the correct run_at is set by delayed job cron
            )
          end # if job exists
        end # each job
      end # each cron_jobs
    end # add_cron_jobs task

  end # setup namespace
end # app namespace
