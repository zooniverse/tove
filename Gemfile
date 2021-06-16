source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'rails', '~> 6.0.4'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 4.3'

gem 'panoptes-client'
gem 'pundit'

# Connect to Azure Storage with Rails Active Storage
gem 'azure-storage'
gem 'azure-storage-blob'

gem 'rubyzip'

# jsonapi.rb is a bundle that incorporates fast_jsonapi (serialization),
# ransack (filtration), and some RSpec matchers along with some
# boilerplate for pagination and error handling
# https://github.com/stas/jsonapi.rb
gem 'jsonapi.rb'

# gem 'redis', '~> 4.0'

gem 'bootsnap', '>= 1.4.2', require: false
gem 'rack-cors'
gem 'sentry-raven'

group :development, :test do
  gem 'coveralls', '~>0.8.23', :require => false
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'jsonapi-rspec', require: false
  gem 'pry-byebug'
  gem 'pry-rails'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.3'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'simplecov'
  gem 'pundit-matchers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
