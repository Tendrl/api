require 'yaml'
require 'securerandom'
require 'bundler'

ENV['RACK_ENV'] ||= 'development'

unless File.exists?('.deploy')
  Bundler.require :default, ENV['RACK_ENV']
else
  require 'sinatra/base'
  require 'etcd'
end

require 'active_support/core_ext/hash'
require 'active_support/inflector'
require './lib/tendrl/version'
require './lib/tendrl/flow'
require './lib/tendrl/node'
require './lib/tendrl/object'
require './lib/tendrl/atom'
require './lib/tendrl/attribute'
require './lib/tendrl/monitoring_api'
require './lib/tendrl/presenters/node_presenter'
require './lib/tendrl/presenters/cluster_presenter'
require './lib/tendrl/presenters/job_presenter'
require './lib/tendrl/presenters/user_presenter'
require './lib/tendrl/presenters/alert_setting_presenter'
require './lib/tendrl/user'
require './lib/tendrl/job'
require './lib/tendrl/validators/user_validator'
require './lib/tendrl/alert_setting'

#Errors
require './lib/tendrl/errors/tendrl_error'
require './lib/tendrl/errors/invalid_object_error'


module Tendrl

  def self.current_definitions
    @cluster_definitions || @node_definitions
  end

  def self.cluster_definitions
    @cluster_definitions
  end

  def self.cluster_definitions=(definitions)
    @node_definitions = nil
    @cluster_definitions = definitions
  end

  def self.node_definitions
    @node_definitions
  end

  def self.node_definitions=(definitions)
    @cluster_definitions = nil
    @node_definitions = definitions
  end

  def self.etcd=(etcd_client)
    @etcd_client ||= etcd_client
  end

  def self.etcd
    @etcd_client
  end

  def self.etcd_config(env)
    if File.exists?('/etc/tendrl/etcd.yml')
      YAML.load_file('/etc/tendrl/etcd.yml')[env.to_sym] 
    else
      YAML.load_file('config/etcd.yml')[env.to_sym] 
    end
  end

end
