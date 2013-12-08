## Translatedesk Prototype

Written in Ruby On Rails 3 (Ruby 1.9) + AngularJS.

### How to run the system

* Run `bundle install` to install missing gems
* NOTE - if you run into issues with the MySQL gem, install it standalone using `gem install mysql`, check the installed version with `gem list | grep mysql` and add this version to the Gemfile ... then run `bundle install`)
* Copy config/database.yml.example to config/database.yml and configure you database... note that if you
  are using SQLite, you need to create the directories where the database files will be stored (which is
  tmp/dbs on the example file, so you need to create them using `mkdir -p tmp/dbs`)
* Copy config/apis.yml.example to config/apis.yml and configure all APIs
* Install [langid.py](https://github.com/saffsd/langid.py), which is used for auto-language detection. For example, installation as a python module: `pip install langid`
* Install `dict`. Ubuntu installation using apt: `apt-get install dict`. Mac installation with homebrew: `brew install dict`
* Optionally install `dictd` and some dictionaries for it, in order to have your own dictionary server; install it on Debian / Ubuntu using `apt-get install dict dictd`.
* Run `rake db:migrate` to create the tables in the database
* Start the server: `rails s`
* Open http://localhost:3000 in your browser
* Check the documention under doc/, which can also be updated by running `rake diagram:all` (uses railroady gem)

### TODO
* Automated tests
* RDOC
* l10n / i18n / pluralization
* Fix FIXMEs: `grep -r FIXME app/*`

### Deployment with Ubuntu 12.04 + Ruby 1.9 + Apache + Passenger

* Install Ruby 1.9.1: `sudo apt-get install ruby1.9.1-full`
* Install Ruby Gems 1.9.1: `sudo apt-get install rubygems1.9.1`
* Define the 1.9.1 version as the default for Ruby: `sudo update-alternatives --config ruby`
* Define the 1.9.1 version as the default for Gem: `sudo update-alternatives --config gem`
* Define the 1.9.1 version as the default for Rake: `sudo update-alternatives --config rake`
* Install the Passenger gem: `sudo gem install passenger`
* Install the Passenger module for Apache: `sudo passenger-install-apache2-module`
* Load Passenger modules for Apache: `cat /etc/apache2/conf.d/rails`

  ```apache
   LoadModule passenger_module /var/lib/gems/1.9.1/gems/passenger-4.0.5/libout/apache2/mod_passenger.so
   PassengerRoot /var/lib/gems/1.9.1/gems/passenger-4.0.5
   PassengerDefaultRuby /usr/bin/ruby1.9.1
  ```

* Create a site for the application on Apache and enable it: `cat /etc/apache2/sites-enabled/translatedesk`

  ```apache
   <VirtualHost *:80>
     ServerName translatedesk.yourdomain.com
     RailsEnv production
     RailsBaseURI /
     DocumentRoot /var/www/translatedesk/public
     <Directory /var/www/translatedesk/public>
       # MultiViews must be turned off.
       Options -MultiViews
     </Directory>
   </VirtualHost>
  ```

* Execute the four first steps of the application installation above

### Extending the application

You can extend Translatedesk by implementing support to a new provider or machine translator.

#### Adding a new machine translator

* Add the class name to Translator::PROVIDERS
* Implement a class on lib/translator/name.rb which needs to have at least two methods: translate (which receives a text, source language code, target language code and a hash of additional options and returns the translated text) and languages (which receives an optional target and hash of options and returns the list of supported languages as codes)
* If the new machine translator requires API keys, add the examples to config/apis.yml.example

Just it. The new machine translator will be available magically on the UI.

#### Adding a new provider

Translatedesk comes with support to Twitter. If you want to give support to another provider, here are the steps (first, you need to think about a unique identifier for it, ideally only letters in lower case, and the provider must be supported on OmniAuth):

* Add a new provider to omniauth_callbacks_controller.rb, so the user can login through this new provider
* On the AngularJS layer, implement a new provider on app/assets/javascripts/translatedesk/providers, check the Twitter one as example
* On the backend, implement a new model on app/models/, that inherits from the Post model
* Add new entry on Post::PROVIDERS (the key is the identifier and the value is the model)
* If the new provider needs API keys, add them to config/apis.yml.example
* Edit or add information on User model as needed
