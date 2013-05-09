source 'https://rubygems.org'
ruby "2.0.0"

gem 'rails', '3.2.12'
gem 'gravatar_image_tag', '1.1.3'
gem 'devise', '2.2.3'
gem 'omniauth-singly', '0.3.0'
gem "oauth", "~> 0.4.7"
gem 'dynamoid', '0.6.1'
gem 'aws-sdk', '1.8.5'
gem 'gmaps4rails', '1.5.6'
gem 'jquery-rails', '2.2.1'
gem 'jquery-ui-rails', '4.0.2'
gem "twitter-bootstrap-rails", "~> 2.2.6"
gem "lazy_high_charts", "~> 1.4.2"
gem "underscore-rails", "1.4.4"
gem "cosm-rb"

if ENV["RAILS_ENV"] == "development"
  gem 'withings-api', :path => '/Users/shechter/src/withings-api'
else 
  if ENV["RAILS_ENV"] == "test"
    gem 'withings-api', :path => '/Users/shechter/src/withings-api'
  else
    gem 'withings-api', :git => 'https://github.com/guyshechter/withings-api.git', :branch => 'master'    
  end
end

if ENV["RAILS_ENV"] == "development"
  gem 'foursquare2', :path => '/Users/shechter/src/foursquare2'
else 
  if ENV["RAILS_ENV"] == "test"
    gem 'foursquare2', :path => '/Users/shechter/src/foursquare2'
  else
    gem 'foursquare2', :git => 'https://github.com/guyshechter/foursquare2.git', :branch => 'master'    
  end
end

group :production do
  gem "pg"
end

group :development, :test do
  gem 'sqlite3', '1.3.7'
  gem 'annotate', '2.5.0'
end

group :development do
  gem 'rspec-rails', '2.13.0'
  gem 'capybara', '2.0.2'
  gem 'webrat', '0.7.3'
end

group :test do
	gem 'rspec-rails', '2.13.0'
  gem 'webrat', '0.7.3'
  gem 'factory_girl_rails', '4.2.1'
  gem 'autotest-rails', '4.1.2'
  gem 'autotest-standalone', '4.5.11'
  gem 'autotest-growl', '0.2.16'
  gem 'autotest-fsevent' 
  gem 'capybara', '2.0.2'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'railties'
  gem 'json'
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end


# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'
