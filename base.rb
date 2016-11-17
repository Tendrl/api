require 'bundler'
require 'yaml'
require 'sinatra/base'
require 'securerandom'
require 'active_support/core_ext/hash'
require 'active_support/inflector'
require 'tendrl'

Bundler.require :default, ENV['RACK_ENV'].to_sym

class Base < Sinatra::Base
  set :root, File.dirname(__FILE__)

  set :env, ENV['RACK_ENV'] || 'development'

  configure do
    set :etcd_config, Proc.new {
      YAML.load_file('config/etcd.yml')[settings.env.to_sym] 
    }
  end

  set :http_allow_methods, [
    'POST',
    'GET',
    'OPTIONS',
    'PUT',
    'DELETE'
  ]

  set :http_allow_headers, [
    'Origin',
    'Content-Type',
    'Accept',
    'Authorization',
  ]

  set :http_allow_origin, [
    '*'
  ]

  set :etcd, Proc.new {
    Etcd.client(
      host: etcd_config[:host],
      port: etcd_config[:port],
      user_name: etcd_config[:user_name],
      password: etcd_config[:password]
    )
  }

  before do
    content_type :json
    response.headers["Access-Control-Allow-Origin"] = 
      settings.http_allow_origin.join(',')
    response.headers["Access-Control-Allow-Methods"] = 
      settings.http_allow_methods.join(',')
    response.headers["Access-Control-Allow-Headers"] = 
      settings.http_allow_headers.join(',')
  end

  get '/ping' do
    { 
      status: 'Ok'
    }.to_json
  end

  get '/GetJobList' do

  end

  protected

  # def http_allowed_methods
  #   settings.http_allowed_methods.join(',')
  # end
  #
  # def http_allowed_headers
  #   settings.http_allowed_headers.join(',')
  # end
  #
  # def http_allowed_origin
  #   settings.http_allowed_origin.join(',')
  # end
  #
  def etcd
    settings.etcd
  end

end
