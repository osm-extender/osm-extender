Some jobs have been provided to make the administration and management of a site easier, these are:

# AutomationTasksJob
Run the automation tasks which users have setup.

# CreateStatisticsJob
Gather site statistics for the days they have not been done for. This will speed up the viewing of statistics graphs as well as making the data marginally more accurate.

# EmailListsJob
Send the notification emails for lists which have changed.

# PruneAnnouncementsJob
Delete all announcements, announcement hiding, and announcement emailed records from longer than 6 months ago. This prevents the database tables getting big enough to cause a slow down due to a large number of announcements.

# PruneBalancedProgrammeCacheJob
Delete the cached data used by the balanced programme checker for any term which has not been accessed in the last year.

# PrunePaperTrailsJob
Delete all paper trail versions over 3 months old.

# PruneUnactivatedUsersJob
Delete nonactivated users whose activation token has expired

# ReminderEmailsJob
Send the reminder emails which users have setup.
