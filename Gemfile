source 'https://rubygems.org'
ruby "2.0.0"

gem 'rails', '3.2.11'
gem 'jquery-rails'
gem 'devise'
gem 'thin'
gem 'pg'
gem 'active_model_serializers'
gem 'bootstrap-sass', '~> 3.0.2.0'
gem 'sass-rails', '>= 3.2'
gem 'compass-rails'
gem 'evernote_oauth'
gem "figaro"
gem 'bcrypt-ruby', '~> 3.1.0'

group :development, :test do
  gem 'quiet_assets', :group => :development
  gem "jasminerice", :git => 'https://github.com/bradphelan/jasminerice.git'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails', '~> 3.2.2'
  gem 'coffee-script-source', '1.5.0'
  gem 'handlebars_assets'
  gem 'uglifier', '>= 1.0.3'
end

group :production do
  gem 'google-analytics-rails'
end