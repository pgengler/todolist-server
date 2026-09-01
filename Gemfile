source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '4.0.6'

gem 'rails', '~> 8.0.0'
gem 'pg'
gem 'puma', '>= 5.0'
gem 'thruster', require: false

gem 'jsonapi-resources', github: 'speee/jsonapi-resources', tag: 'v26.1.3'

gem 'csv'

gem 'devise', '~> 5.0'
gem 'doorkeeper', '~> 5.9'

gem 'acts_as_paranoid', '~> 0.11'

gem 'bootsnap', require: false

gem 'kamal', require: false

group :development, :test do
  gem 'factory_bot_rails'
  gem 'debug', platforms: [:mri, :windows], require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
