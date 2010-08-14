# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_pipes_admin_session',
  :secret      => '33d291f32d89a17d78761a76f285e54886a50851df8df317bac5b201d90de7f1a72a504612fbedeb768f9faa5cf7f171318df00e1e3109733d8845d5683059cd'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
