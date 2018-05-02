The status of your instance can be monitored over https by following the instructions below:

1. Create a random string to use for authentication and add it to the status_keys environment variable (seperate multiple keys with a : ).
2. Pick your format and endpoint from the lists below, append ?key=THE_KEY_YOU_PICKED.

Formats:

* cacti - a simple line of text ready to be parsed by a cacti input method you write.
* json
* csv
* text_table - a simple table created using ASCII text.

End points:

* /status/cache.FORMAT - Details about the redis cache being used by the site, uses the following keys:
  * ram_max - Configured maximum RAM usage
  * ram_used - Current RAM usage
  * keys - Number of keys in the cache
  * cache_hits - Number of cache hits
  * cache_misses - Number of cache misses
  * cache_attempts - Number of cache attempts (hits + misses)
* /status/database_size.FORMAT - Details about the size of the database and tables
  * cacti keys are of the form TABLE_size, TABLE_count for each table and total_count, total_size for the totals
  * csv and text_table have rows for each table showing model name, table name, count and size for each table and a final total row.
  * json is a hash containing two keys:
    * tables - An array of hashes with keys model, table, size and count
    * totals - A hash with keys count and size
* /status/delayed_job.FORMAT - Details of the delayed job queue
  * cacti keys are of the form setting_SOMETHING and jobs_STATE (see json for more details)
  * csv and text_table are tables of the counts of the statuses locked, errored, failed and total
  * json is a hash of hashes with the keys
    * settings
      * default_priority
      * max_attmepts
      * max_run_time
      * sleep_delay
      * destroy_failed_jobs
      * delay_jobs
    * jobs
      * total - The total number of jobs in the queue
      * locked - The number of jobs currently locked
      * failed - The number of jobs that have failed
* /status/unicorn_workers.FORMAT - The number of unicorn workers currently running
* /status/users.FORMAT - How many users the site has split into the following categories:
  * unactivated - Users who have not yet activated their account
  * activated - Users who have activated their account but not yet connected it to OSM
  * connected - Users who have connected their activated account to OSM
  * total - The total number of users
