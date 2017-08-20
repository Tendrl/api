require 'yaml'
require 'securerandom'
require 'bundler'

ENV['RACK_ENV'] ||= 'development'

if File.exist?('.deploy')
  require 'sinatra/base'
  require 'etcd'
  require 'active_model'
  require 'active_support'
  require 'bcrypt'
else
  Bundler.require :default, ENV['RACK_ENV']
end

require 'active_support/core_ext/hash'
require 'active_support/inflector'

# Tendrl core
require './lib/tendrl/version'
require './lib/tendrl/flow'
require './lib/tendrl/object'
require './lib/tendrl/atom'
require './lib/tendrl/attribute'
require './lib/tendrl/http_response_error_handler'

# Models
require './app/models/user'
require './app/models/node'
require './app/models/cluster'
require './app/models/alert'
require './app/models/notification'
require './app/models/job'

# Forms
require './app/forms/user_form'

# Presenters
require './app/presenters/node_presenter'
require './app/presenters/cluster_presenter'
require './app/presenters/job_presenter'
require './app/presenters/user_presenter'

# Errors
require './lib/tendrl/errors/tendrl_error'
require './lib/tendrl/errors/invalid_object_error'

# Contollers
require './app/controllers/application_controller'
require './app/controllers/ping_controller'
require './app/controllers/authenticated_users_controller'
require './app/controllers/nodes_controller'
require './app/controllers/clusters_controller'
require './app/controllers/jobs_controller'
require './app/controllers/users_controller'
require './app/controllers/sessions_controller'
require './app/controllers/alerting_controller'
require './app/controllers/notifications_controller'

# Global Tendrl module
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
    if File.exist?('/etc/tendrl/etcd.yml')
      YAML.load_file('/etc/tendrl/etcd.yml')[env.to_sym]
    else
      YAML.load_file('config/etcd.yml')[env.to_sym]
    end
  end
end
