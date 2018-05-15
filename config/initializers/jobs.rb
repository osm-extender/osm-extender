# Here I'm refering to each job used as a cron job so
# that the rails loader doesn't get a surprise when
# the YAML in delayed_job.handler is parsed.

AutomationTasksJob
CreateStatisticsJob
EmailListsJob
PruneAnnouncementsJob
PruneBalancedProgrammeCacheJob
PrunePaperTrailsJob
PruneUnactivatedUsersJob
ReminderEmailsJob
