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
