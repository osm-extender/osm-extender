# Be sure to restart your server when you modify this file.

# OSMExtender::Application.config.session_store :cookie_store, key: 'session'

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
OSMExtender::Application.config.session_store :db_session_store

#ActionDispatch::Session::ActiveRecordStore.session_class = Session
