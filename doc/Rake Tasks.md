Some rake tasks have been provided to make the administration and management of a site easier, these are:

* app:deploy - this will run the following tasks:
  - db:migrate
  - app:deploy:rollbar - post a deployment to rollbar
* app:setup - this will setup the application for first use, running all of the following tasks:
  - app:setup:first_user - Create the first user for the system
  - app:setup:add_cron_jobs - Create DelayedJob Cron Jobs for the following jobs (unless they already exist):
    - daily (at 3AM):
      - AutomationTasksJob
      - CreateStatisticsJob
      - EmailListsJob
      - PruneUnactivatedUsersJob
      - ReminderEmailsJob
    - monthly (at 1AM on 1st):
      - PruneAnnouncementsJob
      - PruneBalancedProgrammeCacheJob
      - PrunrPaperTrailsJob
* app:wait_for_migrations - wait for any pending migrations to be applied


Some rake tasks have been deprecated in favour of using the corresponding jobs instead:

* scheduled:daily - this will run:
    - scheduled:reminder\_emails - this will send the reminder emails which users have setup.
    - scheduled:email\_lists - this will send the notification emails for lists which have changed.
    - scheduled:automation\_tasks - this will run the automation tasks
    - scheduled:statistics - this will gather site statistics for the days they have not been done for. This will speed up the viewing of statistics graphs as well as making the data marginally more accurate.
    - scheduled:delete\_nonactivated\_users - this will delete nonactivated users whose token has expired
