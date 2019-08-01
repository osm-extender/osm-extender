In order to run the Online Scout Manager Extender System you need to follow these steps.

1. Clone the git repository
1. Fetch the submodules - "git submodule init" then "git submodule update"
1. Ensure you have the right gems "bundle install --without development test" (or just "bundle install" if you want to do some development of OSMX)
1. Contact Ed at [Online Scout Manager](https://www.onlinescoutmanager.co.uk) to get an API ID and token, make a note of these as you'll need them later 
1. Goto [recaptcha](http://recaptcha.net/whyrecaptcha.html) and setup a private/public key pair, make a note of these as you'll need them later
1. Copy all *.example files in config (and its subdirectories) to * and edit them to match your environment
1. Create any config/environments/#{Rails.env}_custom.rb files which you need to (this way any changes you need to make to the environment settings won't be removed by an update)
1. Prepare your database "RAILS_ENV=production bundle exec rake db:setup" (use db:migrate to update it when downloading new code!)
1. Pre compile the asssets - "RAILS_ENV=production bundle exec rake assets:precompile"
1. Integrate it into your web serving architecture (running OSMX in the production environment uses unicorn).
1. Setup the delayed job runner to run every hour - bundle exec rake jobs:workoff
1. Run rake app:setup to create your first user
