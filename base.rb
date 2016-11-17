require 'bundler'
require 'yaml'
require 'sinatra/base'
require "sinatra/multi_route"
require 'securerandom'
require 'active_support/core_ext/hash'
require 'active_support/inflector'
require 'tendrl'

Bundler.require :default, ENV['RACK_ENV'].to_sym

class Base < Sinatra::Base
  register Sinatra::RespondWith
  register Sinatra::CrossOrigin
  register Sinatra::MultiRoute

  set :root, File.dirname(__FILE__)

  set :env, ENV['RACK_ENV'] || 'development'

  enable :cross_origin

  configure do
    set :etcd_config, Proc.new {
      YAML.load_file('config/etcd.yml')[settings.env.to_sym] 
    }
  end

  set :etcd, Proc.new {
    Etcd.client(
      host: etcd_config[:host],
      port: etcd_config[:port],
      user_name: etcd_config[:user_name],
      password: etcd_config[:password]
    )
  }

  protected

  def etcd
    settings.etcd
  end

end
