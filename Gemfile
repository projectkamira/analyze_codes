source 'https://rubygems.org'

# Specify your gem's dependencies in analyze_codes.gemspec
gemspec

gem 'health-data-standards', :git => 'https://github.com/projectcypress/health-data-standards.git', :branch => 'develop'

group :development do
  gem 'rake'
  gem 'pry', '~> 0.9.10'
end

group :test do
  gem 'minitest'
  gem 'turn', :require => false
  gem 'cover_me'
end