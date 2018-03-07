require './lib/tendrl'
require 'etcd'
require 'yaml'
require 'json'
require 'securerandom'

namespace :etcd do
  desc 'Load default Tendrl admin in etcd'
  task :load_admin do
    p 'Generating default Tendrl admin'
    password = 'adminuser'
    user = Tendrl::User.find 'admin'
    if user
      p 'User named admin already exists.'
    else
      Tendrl::User.save({
        name: 'Admin',
        username: 'admin',
        email: 'admin@tendrl.org',
        role: 'admin',
        password: password,
        email_notifications: false
      })
      p 'Generated default admin'
      p 'Username: admin'
      p "Password: #{password}"
    end
  end
end

if ENV['RACK_ENV'] != 'production'
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new :specs do |task|
    task.pattern = Dir['spec/**/*_spec.rb']
  end
  task :default => ['specs']
end
