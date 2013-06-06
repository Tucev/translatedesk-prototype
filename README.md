## Translatedesk Prototype

Written in Ruby On Rails 3 (Ruby 1.9) + AngularJS.

### How to run the system

* Run `bundle install` to install missing gems
* Copy config/database.yml.example to config/database.yml and configure you database
* Copy config/twitter.yml.example to config/twitter.yml and configure you Twitter application settings
* Run `rake db:migrate` to create the tables in the database
* Start the server: `rails s`
* Open http://localhost:3000 in your browser

### TODO:
* Automated tests
* l10n / i18n
