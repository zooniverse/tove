source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'rails', '~> 6.0.1'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 4.3'

gem 'panoptes-client'

# jsonapi.rb is a bundle that incorporates fast_jsonapi (serialization),
# ransack (filtration), and some RSpec matchers along with some
# boilerplate for pagination and error handling
# https://github.com/stas/jsonapi.rb
gem 'jsonapi.rb'

# gem 'redis', '~> 4.0'

gem 'bootsnap', '>= 1.4.2', require: false
gem 'rack-cors'
gem "sentry-raven"

group :development, :test do
  gem 'pry-byebug'
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'jsonapi-rspec', require: false
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'simplecov'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
