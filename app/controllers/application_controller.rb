require 'tendrl'
class ApplicationController < Sinatra::Base
  set :root, File.dirname(__FILE__)

  set :environment, ENV['RACK_ENV'] || 'development'

  set :logging, true

  set :logging, ENV['LOG_LEVEL'] || Logger::INFO

  configure :development do
    set :etcd_config, Proc.new {
      Tendrl.etcd_config(settings.environment)
    }
  end

  configure :test do
    set :etcd_config, Proc.new {
      {}
    }
  end

  configure :production do
    set :etcd_config, Proc.new {
      Tendrl.etcd_config(settings.environment)
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
    'X-Requested-With'
  ]

  set :http_allow_origin, [
    '*'
  ]

  error Etcd::NotDir do
    halt 404, { errors: { message: 'Not found.' }}.to_json
  end

  error Etcd::KeyNotFound do
    halt 404, { errors: { message: 'Not found.' }}.to_json
  end

  before do
    content_type :json
    response.headers["Access-Control-Allow-Origin"] = 
      settings.http_allow_origin.join(',')
    response.headers["Access-Control-Allow-Methods"] = 
      settings.http_allow_methods.join(',')
    response.headers["Access-Control-Allow-Headers"] = 
      settings.http_allow_headers.join(',')
  end

  before do
    Tendrl.etcd = Etcd.client(
      host: settings.etcd_config[:host],
      port: settings.etcd_config[:port],
      user_name: settings.etcd_config[:user_name],
      password: settings.etcd_config[:password]
    )
  end

  options '*' do
    status 200
  end

  protected

  def access_token
    token = nil
    if request.env['HTTP_AUTHORIZATION']
      token = request.env['HTTP_AUTHORIZATION'].split('Bearer ')[-1]
    end
    token
  end

  def etcd
    Tendrl.etcd
  end

  def recurse(parent, attrs={})
    parent_key = parent.key.split('/')[-1].downcase
    return attrs if ['definitions', 'raw_map'].include?(parent_key)
    parent.children.each do |child|
      child_key = child.key.split('/')[-1].downcase
      attrs[parent_key] ||= {}
      if child.dir
        recurse(child, attrs[parent_key])
      else
        if attrs[parent_key]
          attrs[parent_key][child_key] = child.value
        else
          attrs[child_key] = child.value
        end
      end
    end
    attrs
  end

end
