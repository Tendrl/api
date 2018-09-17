class ClustersController < AuthenticatedUsersController
  get '/clusters' do
    clusters = Tendrl::Cluster.all
    JSON.generate clusters: clusters
  end

  before '/clusters/:cluster_id/?*?' do
    @cluster = Tendrl::Cluster.find(params[:cluster_id])
    raise Tendrl::HttpResponseErrorHandler.new(
      StandardError.new,
      cause: '/clusters/id',
      object_id: params[:cluster_id]
    )
  end

  get '/clusters/:cluster_id' do
    state = @cluster.gd2.state
    state.to_json
  end

  get '/clusters/:cluster_id/peers' do
    peers = @cluster.gd2.peers
    { peers: peers }.to_json
  end

  get '/clusters/:cluster_id/volumes' do
    volumes = @cluster.gd2.volumes
    { volumes: volumes }.to_json
  end

  get '/clusters/:cluster_id/volumes/:volume_id' do
    volume = @cluster.gd2.volumes(params[:volume_id])
    { volume: volume }.to_json
  end

  get '/clusters/:cluster_id/volumes/:volume_id/bricks' do
    bricks = @cluster.gd2.bricks(params[:volume_id])
    { bricks: bricks }.to_json
  end

  post '/import' do
    new_endpoint = {
      'gd2_url' => parsed_body['gd2_url'],
      'secret' => parsed_body['secret']
    }
    gd2 = Gd2Client.new new_endpoint.symbolize_keys
    state = gd2.state
    cluster = Tendrl::Cluster.new state['cluster-id']
    unless cluster.endpoints.include? new_endpoint
      cluster.add_endpoint new_endpoint
    end
    status 201
    state.merge(endpoints: cluster.endpoints).to_json
  end

  #get '/clusters/:cluster_id/nodes/:node_id/bricks' do
    #bricks = @cluster.gd2.get("/endpoints")
    #{ bricks: bricks }.to_json
  #end

  #get '/clusters/:cluster_id/notifications' do
    #notifications = Tendrl::Notification.all
    #NotificationPresenter.list_by_integration_id(notifications, params[:cluster_id]).to_json
  #end

  #get '/clusters/:cluster_id/jobs' do
    #begin
      #jobs = Tendrl::Job.all
    #rescue Etcd::KeyNotFound
      #jobs = []
    #end
    #{ jobs: JobPresenter.list_by_integration_id(jobs, params[:cluster_id]) }.to_json
  #end

  #post '/clusters/:cluster_id/unmanage' do
    #Tendrl.load_node_definitions
    #flow = Tendrl::Flow.new('namespace.tendrl', 'UnmanageCluster')
    #body = JSON.parse(request.body.string.present? ? request.body.string : '{}')
    #job = Tendrl::Job.new(
      #current_user,
      #flow,
      #integration_id: params[:cluster_id]).create(body)
    #status 202
    #{ job_id: job.job_id }.to_json
  #end

  #post '/clusters/:cluster_id/expand' do
    #Tendrl.load_node_definitions
    #flow = Tendrl::Flow.new 'namespace.tendrl', 'ExpandClusterWithDetectedPeers'
    #job = Tendrl::Job.new(
      #current_user,
      #flow,
      #integration_id: params[:cluster_id]
    #).create({})
    #status 202
    #{ job_id: job.job_id }.to_json
  #end

  #post '/clusters/:cluster_id/profiling' do
    #Tendrl.load_definitions(params[:cluster_id])
    #body = JSON.parse(request.body.read)
    #volume_profiling_flag = if ['enable', 'disable'].include?(body['Cluster.volume_profiling_flag'])
                              #body['Cluster.volume_profiling_flag']
                            #else
                              #'leave-as-is'
                            #end
    #flow = Tendrl::Flow.new('namespace.gluster', 'EnableDisableVolumeProfiling')

    #job = Tendrl::Job.new(
        #current_user,
        #flow,
        #integration_id: params[:cluster_id],
        #type: 'sds'
    #).create('Cluster.volume_profiling_flag' => volume_profiling_flag)
    #status 202
    #{ job_id: job.job_id }.to_json
  #end

  #post '/clusters/:cluster_id/volumes/:volume_id/start_profiling' do
    #Tendrl.load_definitions(params[:cluster_id])
    #flow = Tendrl::Flow.new('namespace.gluster', 'StartProfiling', 'Volume')
    #job = Tendrl::Job.new(
      #current_user,
      #flow,
      #integration_id: params[:cluster_id],
      #type: 'sds'
    #).create('Volume.vol_id' => params[:volume_id])
    #status 202
    #{ job_id: job.job_id }.to_json
  #end

  #post '/clusters/:cluster_id/volumes/:volume_id/stop_profiling' do
    #Tendrl.load_definitions(params[:cluster_id])
    #flow = Tendrl::Flow.new('namespace.gluster', 'StopProfiling', 'Volume')
    #job = Tendrl::Job.new(
      #current_user,
      #flow,
      #integration_id: params[:cluster_id],
      #type: 'sds'
    #).create('Volume.vol_id' => params[:volume_id])
    #status 202
    #{ job_id: job.job_id }.to_json
  #end
end
