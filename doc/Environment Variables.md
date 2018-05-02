| Variable              | Required? | Default   | Purpose                                           | Notes                                         |
|:--------------------- |:--------- |:--------- |:------------------------------------------------- |:--------------------------------------------- |
| secret_key_base       | yes       |           | Security features in rails                        | Generate by running 'bundle exec rake secret' |
| osm_api_name          | yes       |           | Allows user's to tell your API from others in OSM | You'll give this to OSM when getting API keys |
| osm_api_id            | yes       |           | Used to make API requests to OSM                  | OSM will provide this to you getting API keys |
| osm_api_token         | yes       |           | Used to make API requests to OSM                  | OSM will provide this to you getting API keys |
| recaptcha_public_key  | yes       |           | Used to prevent abuse of contact us form          |                                               |
| recaptcha_private_key | yes       |           | Used to prevent abuse of contact us form          |                                               |
| ga_tracking_id        |           |           | Used to get usage analytics for the site          |                                               |
| signup_code           |           |           | Used to limit signups to people with this code    |                                               |
| rollbar_access_token  | yes       |           | Used for reporting errors to rollbar              |                                               |
| mailgun_domain        | yes       |           | The domain OSMX will be sending email from        |                                               |
| mailgun_api_key       | yes       |           | Used to authenticate OSMX to mailgun              |                                               |
| status_keys           |           |           | Used to provide signinless status fetching        | Seperate multiple keys with a :               |
| database_host         |           | localhost | Database host name                                |                                               |
| database_name         | yes       |           | The database name to use                          |                                               |
| database_username     | yes       |           | The username for authenticating to the database   |                                               |
| database_password     | yes       |           | The password for authenticating to the database   |                                               |
| database_pool         |           | 5         | The pool size to use for database connections     |                                               |
| database_timeout      |           | 5000      | The timeout for connecting to the database (ms)   |                                               |
