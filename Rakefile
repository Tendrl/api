require './lib/tendrl'
require 'etcd'
require 'yaml'
require 'json'
require 'securerandom'

ENV['RACK_ENV'] ||= 'development'

namespace :etcd do
  desc 'Load etcd with seed data'
  task :seed do
    etcd_config = YAML.load_file('config/etcd.yml')[ENV['RACK_ENV'].to_sym]
    etcd = Etcd.client(
      host: etcd_config[:host],
      port: etcd_config[:port],
      user_name: etcd_config[:user_name],
      password: etcd_config[:password]
    )
    cluster_id = SecureRandom.uuid
    etcd.set("/clusters/#{cluster_id}", dir: false, value: { cluster_id: cluster_id, sds_version: 'gluster-3.8.3' }.to_json)
    p "Sample cluster id generated #{cluster_id}"
  end
end
