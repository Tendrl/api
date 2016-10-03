source 'https://rubygems.org'

ruby '2.3.1'

gem 'sinatra'
gem 'sinatra-contrib'
gem 'etcd'
gem 'sinatra-cross_origin', "~> 0.3.1"
gem 'activesupport', require: false

group :development do
  gem 'rubocop', require: false
  gem 'shotgun'
end

group :test do
  gem 'rspec'
  gem 'rack-test'
end

group :production do
  gem 'puma'
end

