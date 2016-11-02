require 'bundler'
require 'yaml'
require 'sinatra/base'
require "sinatra/multi_route"
require 'securerandom'
require 'active_support/core_ext/hash'
require './lib/tendrl'

Bundler.require :default, ENV['RACK_ENV'].to_sym

class App < Sinatra::Base
  register Sinatra::RespondWith
  register Sinatra::CrossOrigin
  register Sinatra::MultiRoute

  set :root, File.dirname(__FILE__)

  set :env, ENV['RACK_ENV'] || 'development'

  enable :cross_origin

  configure :development, :test do
    set :etcd_config, Proc.new {
      YAML.load_file('config/etcd.yml')[settings.env.to_sym] 
    }
  end

  configure :production do
    set :etcd_config, Proc.new {
      YAML.load(ERB.new(File.read('config/etcd_prod.yml')).result)[settings.env.to_sym] 
    }
  end

  before do
    Tendrl.sds_config
  end

  set :etcd, Proc.new {
    Etcd.client(
      host: etcd_config[:host],
      port: etcd_config[:port],
      user_name: etcd_config[:user_name],
      password: etcd_config[:password]
    )
  }

  get '/cluster/:cluster_id/:object_type/attributes' do
    cluster = JSON.parse(etcd.get("/clusters/#{params[:cluster_id]}").value)
    component = Tendrl::Component.new(cluster['sds_version'],
                                      params[:object_type])

    respond_to do |f|
      f.json { component.attributes.to_json }
    end
  end

  get '/cluster/:cluster_id/:object_type/actions' do
    cluster = JSON.parse(etcd.get("/clusters/#{params[:cluster_id]}").value)
    component = Tendrl::Component.new(cluster['sds_version'],
                                      params[:object_type])

    respond_to do |f|
      f.json { component.actions.to_json }
    end
  end

  post '/cluster/:cluster_id/:object_type/:action' do
    cluster = JSON.parse(etcd.get("/clusters/#{params[:cluster_id]}").value)
    component = Tendrl::Component.new(cluster['sds_version'],
                                      params[:object_type])
    body = JSON.parse(request.body.read)
    job_id = SecureRandom.uuid
    etcd.set("/queue/#{job_id}", value: {
      cluster_id: params[:cluster_id],
      sds_nvr: cluster['sds_version'],
      action: params[:action],
      object_type: params[:object_type],
      status: 'processing',
      attributes: body.slice(*component.attributes.keys)
    }.to_json)

    job = { 
      job_id: job_id,
      status: 'processing',
      sds_nvr: cluster['sds_version'],
      action: params[:action],
      object_type: params[:object_type] 
    }

    respond_to do |f|
      status 202
      f.json { job.to_json }
    end
  end

  private

  def etcd
    settings.etcd
  end

end
