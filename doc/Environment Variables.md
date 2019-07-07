| Variable                        | Required? | Default               | Purpose                                           | Notes                                                       |
|:------------------------------- |:--------- |:--------------------- |:------------------------------------------------- |:----------------------------------------------------------- |
| RAILS_ENV                       |           | development           | Which environment to run rails in                 | developmnet, staging or production                          | 
| secret_key_base                 | yes       |                       | Security features in rails                        | Generate by running 'bundle exec rake secret'               |
| osm_api_name                    | yes       |                       | Allows user's to tell your API from others in OSM | You'll give this to OSM when getting API keys               |
| osm_api_id                      | yes       |                       | Used to make API requests to OSM                  | OSM will provide this to you getting API keys               |
| osm_api_token                   | yes       |                       | Used to make API requests to OSM                  | OSM will provide this to you getting API keys               |
| recaptcha_public_key            | no        |                       | Used to prevent abuse of contact us form          |                                                             |
| recaptcha_private_key           | no        |                       | Used to prevent abuse of contact us form          |                                                             |
| ga_tracking_id                  |           |                       | Used to get usage analytics for the site          |                                                             |
| signup_code                     |           |                       | Used to limit signups to people with this code    |                                                             |
| rollbar_access_token            | no        |                       | Used for reporting errors to rollbar              |                                                             |
| mailgun_domain                  | yes       |                       | The domain OSMX will be sending email from        |                                                             |
| mailgun_api_key                 | yes       |                       | Used to authenticate OSMX to mailgun              |                                                             |
| mailgun_api_host                |           | api.eu.mailgun.net    |                                                   |                                                             |
| status_keys                     |           |                       | Used to provide signinless status fetching        | Seperate multiple keys with a :                             |
| routes_host                     | yes       |                       | The hostname to use when generating routes        |                                                             |
| database_host                   |           | localhost             | Database host name                                |                                                             |
| database_name                   | yes       |                       | The database name to use                          |                                                             |
| database_username               | yes       |                       | The username for authenticating to the database   |                                                             |
| database_password               | yes       |                       | The password for authenticating to the database   |                                                             |
| database_pool                   |           | 5                     | The pool size to use for database connections     |                                                             |
| database_timeout                |           | 5000                  | The timeout for connecting to the database (ms)   |                                                             |
| redis_host                      |           | 127.0.0.1             |                                                   |                                                             |
| redis_port                      |           | 6379                  |                                                   |                                                             |
| redis_db                        |           | 0                     |                                                   |                                                             |
| redis_password                  |           |                       |                                                   |                                                             |
| redis_namespace                 |           | osmx.RAILS_ENV        |                                                   |                                                             |
| redis_expires_in                |           | 600                   |                                                   |                                                             |
| contact_us_to_address           | yes       |                       | The email address to send contact us forms to     |                                                             |
| user_mailer_from_name           |           | OSM Extender          | The name to send user mailer emails from          |                                                             |
| user_mailer_from_mailname       |           | system                | The mail name to send user mailer email from      | Gets prepended to @mailgun_domain to make en email address. |
| email_reminder_from_name        |           | OSMX Reminders        | The name to send email reminders from             |                                                             |
| email_reminder_from_mailname    |           | reminders             | The mail name to send email reminders from        | Gets prepended to @mailgun_domain to make en email address. |
| automation_task_from_name       |           | OSMX Automation Tasks | The name to send automation task emails from      |                                                             |
| automation_task_from_mailname   |           | automation-tasks      | The mail name to send automation task email from  | Gets prepended to @mailgun_domain to make en email address. |
| email_list_mailer_from_name     |           | OSMX Notifications    | The name to send notification emails from         |                                                             |
| email_list_mailer_from_mailname |           | notifications         | The mail name to send notification email from     | Gets prepended to @mailgun_domain to make en email address. |
| contact_us_from_name            |           | OSMX Contact Us       | The name to send contact us emails from           |                                                             |
| contact_us_from_mailname        |           | contactus             | The mail name to send contact us email from       | Gets prepended to @mailgun_domain to make en email address. |
