require 'tendrl'

class Base < Sinatra::Base
  set :root, File.dirname(__FILE__)

  set :environment, ENV['RACK_ENV'] || 'development'

  set :logging, true

  set :logging, ENV['LOG_LEVEL'] || Logger::INFO

  configure :development, :test do
    set :etcd_config, Proc.new {
      YAML.load_file('config/etcd.yml')[settings.environment.to_sym] 
    }
  end

  configure :production do
    set :etcd_config, Proc.new {
      if File.exists?('/etc/tendrl/etcd.yml')
        YAML.load_file('/etc/tendrl/etcd.yml')[settings.environment.to_sym] 
      else
        YAML.load_file('config/etcd.yml')[settings.environment.to_sym] 
      end
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

  get '/jobs' do
    jobs = []
    etcd.get('/queue', recursive: true).children.each do |job|
      job = JSON.parse(job.value)
      jobs << JobPresenter.single(job) if job['created_from'] == 'API'
    end
    jobs.to_json
  end

  get '/jobs/:job_id' do
    jobs = []
    job = JSON.parse(etcd.get("/queue/#{params[:job_id]}").value)
    JobPresenter.single(job).to_json
  end

  get '/jobs/:job_id/logs' do
    params[:type] ||= 'all'
    job = JSON.parse(etcd.get("/queue/#{params[:job_id]}").value)
    request_id = job['request_id']
    logs = etcd.get("/#{request_id}/#{params[:type]}").value
    { logs: logs, type: params[:type] }.to_json
  end

  protected

  def monitoring
    yaml = etcd.get('/_tendrl/config/performance_monitoring').value
    config = YAML.load(yaml)
    @monitoring = Tendrl::MonitoringApi.new(config)
  rescue Etcd::KeyNotFound
    logger.info 'Monitoring API not enabled.'
    nil
  end

  def etcd
    settings.etcd
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
