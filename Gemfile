source 'https://rubygems.org'

ruby '2.0.0'

gem 'sinatra'
gem 'sinatra-contrib'
gem 'etcd'
gem 'sinatra-cross_origin', "~> 0.3.1"
gem 'activesupport', "4.2.2", require: false

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

