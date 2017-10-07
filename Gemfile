source 'https://rubygems.org'

ruby '2.0.0'

gem 'sinatra', '1.4.5', require: 'sinatra/base'
gem 'etcd', '0.3.0'
gem 'activesupport', "4.2.6", require: false
gem 'activemodel', '4.2.6', require: 'active_model'
gem 'rake', '0.9.6'
gem 'puma', '3.6.0'
gem 'bcrypt', '3.1.11'

group :development do
  gem 'rubocop', require: false
  gem 'shotgun'
  gem 'rb-readline'
end

group :test do
  gem 'rspec'
  gem 'rack-test'
  gem 'webmock'
  gem 'simplecov', :require => false
  gem 'rest-client'
end


group :documentation do
  gem 'asciidoctor'
end

gem 'ruby-prof', require: false
