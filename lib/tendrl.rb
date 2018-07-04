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

# Global Tendrl module
module Tendrl
  class << self
    def current_definitions
      @cluster_definitions || @node_definitions
    end

    def cluster_definitions
      @cluster_definitions
    end

    def cluster_definitions=(definitions)
      @node_definitions = nil
      @cluster_definitions = definitions
    end

    def node_definitions
      @node_definitions
    end

    def node_definitions=(definitions)
      @cluster_definitions = nil
      @node_definitions = definitions
    end

    def load_node_definitions
      defs = etcd.cached_get('/_NS/node_agent/compiled_definitions/data').value
      self.node_definitions = YAML.load JSON.parse(defs)['data']
    rescue Etcd::KeyNotFound => e
      raise Tendrl::HttpResponseErrorHandler.new(
        e, cause: '/_tendrl/definitions'
      )
    end

    def load_definitions(cluster_id)
      defs = etcd.cached_get("/clusters/#{cluster_id}/_NS/definitions/data").value
      self.cluster_definitions = YAML.load JSON.parse(defs)['data']
    rescue Etcd::KeyNotFound => e
      raise Tendrl::HttpResponseErrorHandler.new(
        e, cause: '/clusters/definitions', object_id: cluster_id
      )
    end

    def etcd_config=(config)
      $etcd_config = config.freeze
    end

    def etcd_config
      $etcd_config
    end

    def etcd=(etcd_client)
      $etcd_client = etcd_client.freeze
    end

    def etcd
      $etcd_client
    end

    def load_config(env)
      if File.exist?('/etc/tendrl/etcd.yml')
        YAML.load_file('/etc/tendrl/etcd.yml')[env.to_sym]
      elsif File.exists?('config/etcd.yml')
        YAML.load_file('config/etcd.yml')[env.to_sym] || {}
      else
        {}
      end
    end

    def load_cert_config(config)
      {
        use_ssl:  true,
        ca_file:  config[:ca_cert_file],
        ssl_cert: load_client_cert(config[:client_cert_file]),
        ssl_key:  load_client_key(config[:client_key_file], config[:passphrase])
      }
    end

    def load_client_cert(path)
      OpenSSL::X509::Certificate.new(File.read(path))
    end

    def load_client_key(path, passphrase)
      OpenSSL::PKey::RSA.new(File.read(path), passphrase)
    end

    def recurse(parent, attrs = {}, options = {})
      downcase_keys = options[:downcase_keys].nil? || options[:downcase_keys]
      parent_key = parent.key.split('/')[-1]
      parent_key = parent_key.downcase if downcase_keys
      return attrs if ['definitions', 'raw_map'].include?(parent_key)
      parent.children.each do |child|
        child_key = child.key.split('/')[-1]
        child_key = child_key.downcase if downcase_keys
        attrs[parent_key] ||= {}
        if child.dir
          recurse(child, attrs[parent_key], options)
        else
          attrs[parent_key][child_key] = child.value
          unmarshall! attrs[parent_key]
        end
      end
      attrs
    end

    def unmarshall!(attrs)
      # data can be our serialized data, or a 'data' attribute which is not json
      data_value = attrs.delete 'data'
      data = JSON.parse(data_value) rescue { 'data' => data_value }
      attrs.merge! data if data_value
      attrs
    end
  end
end

# Initializers
require './config/initializers/etcd'

# Tendrl core
require './lib/tendrl/version'
require './lib/tendrl/flow'
require './lib/tendrl/object'
require './lib/tendrl/atom'
require './lib/tendrl/attribute'
require './lib/tendrl/http_response_error_handler'
require './lib/gd2_client'

# Models
require './app/models/user'
require './app/models/node'
require './app/models/cluster'
require './app/models/alert'
require './app/models/notification'
require './app/models/job'
require './app/models/volume'
require './app/models/brick'
require './app/models/peer'

# Forms
require './app/forms/user_form'

# Presenters
require './app/presenters/node_presenter'
require './app/presenters/cluster_presenter'
require './app/presenters/job_presenter'
require './app/presenters/user_presenter'
require './app/presenters/volume_presenter'
require './app/presenters/brick_presenter'
require './app/presenters/notification_presenter'

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
