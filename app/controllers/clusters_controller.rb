class ClustersController < AuthenticatedUsersController
  get '/clusters' do
    clusters = Tendrl::Cluster.all
    { clusters: clusters }.to_json
  end

  before '/clusters/:cluster_id/?*?' do
    @cluster = Tendrl::Cluster.find(params[:cluster_id])
    unless @cluster.present?
      raise Tendrl::HttpResponseErrorHandler.new(
        StandardError.new,
        cause: '/clusters/id',
        object_id: params[:cluster_id]
      )
    end
  end

  get '/clusters/:cluster_id' do
    @cluster.to_json
  end

  get '/clusters/:cluster_id/peers' do
    peers = @cluster.gd2.get_peers.to_a
    { peers: peers }.to_json
  end

  get '/clusters/:cluster_id/volumes' do
    volumes = @cluster.gd2.volume_list.to_a
    { volumes: volumes }.to_json
  end

  get '/clusters/:cluster_id/volumes/:volname' do
    volume = @cluster.gd2.volume_info(params[:volname]).to_a
    { volume: volume }.to_json
  end

  post '/clusters/:cluster_id/volumes/:volname/start' do
    @cluster.gd2.volume_start(params[:volname]).body
  end

  post '/clusters/:cluster_id/volumes/:volname/stop' do
    @cluster.gd2.volume_stop(params[:volname]).body
  end

  get '/clusters/:cluster_id/volumes/:volname/bricks' do
    bricks = @cluster.gd2.volume_bricks_status(params[:volname]).to_a
    { bricks: bricks }.to_json
  end

  post '/import' do
    new_endpoint = {
      'gd2_url' => parsed_body['gd2_url'],
      'user' => parsed_body['user'],
      'secret' => parsed_body['secret']
    }
    gd2 = Gd2Client.new new_endpoint
    halt 404, 'Invalid endpoint' unless gd2.ping? && gd2.generate_api_methods
    state = gd2.statedump.to_h
    cluster = Tendrl::Cluster.new state['cluster-id']
    unless cluster.data['endpoints'].include? new_endpoint
      cluster.add_endpoint state['peer-id'], new_endpoint
    end
    cluster.add_short_name(parsed_body['short_name'])
    begin
      # TODO Publish webhook to GD2 as below:
      # cluster.gd2.events_webhook_add(url: "http://<tendrl_server>/api/1.0/clusters/#{cluster.uuid}/event_webhook")
      # TODO See below for event_webhook API.
    rescue Tendrl::HttpResponseErrorHandler => e
      details = e.body[:errors][:details]
      raise e unless details.present? && details['errors'].first['code'].to_s == '1'
    end
    status 201
    cluster.to_json
  end

  # Server sent events for subscribing to glusterd2 events
  # TODO Add https://github.com/remy/polyfills/blob/master/EventSource.js polyfill to UI
  # TODO Use http://walterbm.github.io/blog/2015/10/07/sinatra-and-server-sent-events/ as a reference on how to consume this in UI
  connections = []
  get '/clusters/:cluster_id/event_stream', provides: 'text/event-stream' do
    stream(:keep_open) do |out|
      connections << out
      connections.reject!(&:closed?)
    end
  end

  # This API listens to events from this cluster (to be published to GD2 as part of import)
  # TODO Publish events to interested clients that have connected to the event_stream API
  # TODO This API should also call prometheus alertmanager APIs if necessary
  # TODO Add metric scraping jobs to prometheus server config, so that gluster-prometheus data starts appearing in our prometheus instance
  post '/clusters/:cluster_id/event_webhook' do
    connections.each do |conn|
      conn << '{"data": "foobar"}'+"\n\n"
    end
  end

  get '/clusters/:cluster_id/events' do
    { events: @cluster.gd2.events_list.to_a }.to_json
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
