require 'yaml'
require 'securerandom'
require 'bundler'

begin
  Bundler.require :default, ENV['RACK_ENV'].to_sym
rescue Bundler::GemNotFound
  require 'sinatra/base'
  require 'etcd'
end

require 'active_support/core_ext/hash'
require 'active_support/inflector'
require 'active_support/core_ext/hash/deep_merge'
require './lib/tendrl/version'
require './lib/tendrl/flow'
require './lib/tendrl/object'
require './lib/tendrl/atom'
require './lib/tendrl/attribute'

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

end
