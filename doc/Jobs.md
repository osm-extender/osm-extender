Some jobs have been provided to make the administration and management of a site easier, these are:

# AutomationTasksJob
Run the automation tasks which users have setup.
Is run by the scheduled:automation\_tasks rake task, run daily.

# CreateStatisticsJob
Gather site statistics for the days they have not been done for. This will speed up the viewing of statistics graphs as well as making the data marginally more accurate.
Is run by the scheduled:statistics rake task, suggested to run daily.

# EmailListsJob
Send the notification emails for lists which have changed.
Is run by the scheduled:email\_lists rake task, run daily.

# PruneAnnouncementsJob
Delete all announcements, announcement hiding, and announcement emailed records from longer than 6 months ago. This prevents the database tables getting big enough to cause a slow down due to a large number of announcements.
Is run by the scheduled:clean:announcements rake task, suggested to run monthly.

# PruneBalancedProgrammeCacheJob
Delete the cached data used by the balanced programme checker for any term which has not been accessed in the last year.
Is run by the scheduled:clean:balanced\_programme\_cache rake task, suggested to run monthly.

# PrunePaperTrailsJob
Delete all paper trail versions over 3 months old.
Is run by the scheduled:clean:paper_trail rake task, suggested to run monthly.

# PruneUnactivatedUsersJob
Delete nonactivated users whose activation token has expired
Is run by the scheduled:delete\_nonactivated\_users rake task, suggested to run daily.

# ReminderEmailsJob
Send the reminder emails which users have setup.
Is run by the scheduled:reminder\_emails rake task, run daily.
