require './lib/tendrl'
require 'etcd'
require 'yaml'
require 'json'
require 'securerandom'
require 'rspec/core/rake_task'

namespace :etcd do
  desc 'Load default Tendrl admin in etcd'
  task :load_admin do
    p 'Generating default Tendrl admin'
    etcd_config = Tendrl.etcd_config(ENV['RACK_ENV'])
    password = SecureRandom.hex(4)
    Tendrl.etcd = Etcd.client(
      host: etcd_config[:host],
      port: etcd_config[:port],
      user_name: etcd_config[:user_name],
      password: etcd_config[:password]
    )
    begin
      user = Tendrl::User.find 'admin'
      p 'User named admin already exists.'
    rescue Etcd::KeyNotFound
      Tendrl::User.save({
        name: 'Admin',
        username: 'admin',
        email: '',
        role: 'admin',
        password: password
      })
      p 'Generated default admin'
      p 'Username: admin'
      p "Password: #{password}"
    end
  end
end

RSpec::Core::RakeTask.new :specs do |task|
  task.pattern = Dir['spec/**/*_spec.rb']
end

task :default => ['specs']
