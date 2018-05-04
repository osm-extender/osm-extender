Some rake tasks have been provided to make the administration and management of a site easier, these are:

* app:setup - this will setup the application for first use.
* scheduled:monthly - this will run:
    - scheduled:clean:all - this will run:
        * scheduled:clean:balanced\_programme\_cache - this will delete the cached data used by the balanced programme checker for any term which has not been accessed in the last year.
        * scheduled:clean:announcements - this will delete all announcements, announcement hiding, and announcement emailed records from a while ago. This prevents the database tables getting big enough to cause a slow down due to a large number of announcements.
        * scheduled:clean:paper_trail - this will delete all paper trail versions over 1 year old.
* scheduled:daily - this will run:
    - scheduled:reminder\_emails - this will send the reminder emails which users have setup.
    - scheduled:email\_lists - this will send the notification emails for lists which have changed.
    - scheduled:automation\_tasks - this will run the automation tasks
    - scheduled:statistics - this will gather site statistics for the days they have not been done for. This will speed up the viewing of statistics graphs as well as making the data marginally more accurate.
    - scheduled:delete\_nonactivated\_users - this will delete nonactivated users whose token has expired
