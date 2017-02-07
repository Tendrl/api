class ClustersController < AuthenticatedUsersController

  get '/GetClusterList' do
    clusters = []
    etcd.get('/clusters', recursive: true).children.each do |cluster|
      clusters << recurse(cluster) 
    end
    clusters = ClusterPresenter.list(clusters)
    #clusters = load_stats(clusters)
    { clusters: clusters }.to_json
  end

  get '/:cluster_id/Flows' do
    cluster = cluster(params[:cluster_id])
    flows = Tendrl::Flow.find_all
    flows.to_json
  end

  get %r{\/([a-zA-Z0-9-]+)\/Get(\w+)List} do |cluster_id, object_name|
    cluster = cluster(cluster_id)
    objects = []
    begin
      etcd.get(
        "/clusters/#{cluster['integration_id']}/#{object_name.pluralize}", recursive: true
      ).children.each do |node|
        objects << recurse(node)
      end
    rescue Etcd::KeyNotFound, Etcd::NotDir

    end
    objects.to_json
  end

  post '/:cluster_id/:flow' do
    cluster = cluster(params[:cluster_id])
    flow = Tendrl::Flow.find_by_external_name_and_type(
      params[:flow], 'cluster'
    )
    halt 404 if flow.nil?
    body = JSON.parse(request.body.read)
    body['TendrlContext.integration_id'] = cluster.delete('integration_id')
    job_id = SecureRandom.uuid
    job = etcd.set(
      "/queue/#{job_id}", 
      value: {
        integration_id: params[:cluster_id],
        job_id: job_id,
        status: 'new',
        parameters: body,
        run: flow.run,
        flow: flow.flow_name,
        type: 'sds',
        created_from: 'API',
        created_at: Time.now.utc.iso8601,
        node_ids: node_ids(params[:cluster_id])
      }.
      to_json
    )
    status 202
    { job_id: job_id }.to_json
  end

  put '/:cluster_id/:flow' do
    cluster = cluster(params[:cluster_id])
    flow = Tendrl::Flow.find_by_external_name_and_type(
      params[:flow], 'cluster'
    )
    halt 404 if flow.nil?
    body = JSON.parse(request.body.read)
    body['TendrlContext.integration_id'] = cluster.delete('integration_id')
    job_id = SecureRandom.uuid
    job = etcd.set(
      "/queue/#{job_id}", 
      value: {
        integration_id: params[:cluster_id],
        job_id: job_id,
        status: 'new',
        parameters: body,
        run: flow.run,
        flow: flow.flow_name,
        type: 'sds',
        created_from: 'API',
        created_at: Time.now.utc.iso8601,
        node_ids: node_ids(params[:cluster_id])
      }.
      to_json
    )
    status 202
    { job_id: job_id }.to_json
  end


  delete '/:cluster_id/:flow' do
    cluster = cluster(params[:cluster_id])
    flow = Tendrl::Flow.find_by_external_name_and_type(
      params[:flow], 'cluster'
    )
    halt 404 if flow.nil?
    body = JSON.parse(request.body.read)
    body['TendrlContext.integration_id'] = cluster.delete('integration_id')
    job_id = SecureRandom.uuid
    job = etcd.set(
      "/queue/#{job_id}", 
      value: {
        integration_id: params[:cluster_id],
        job_id: job_id,
        status: 'new',
        parameters: body,
        run: flow.run,
        flow: flow.flow_name,
        type: 'sds',
        created_from: 'API',
        created_at: Time.now.utc.iso8601,
        node_ids: node_ids(params[:cluster_id])
      }.
      to_json
    )
    status 202
    { job_id: job_id }.to_json
  end

  private

  def cluster(cluster_id)
    load_definitions(cluster_id)
    @cluster ||=
      recurse(etcd.get("/clusters/#{cluster_id}/TendrlContext"))['tendrlcontext']
  end

  def node_ids(cluster_id)
    node_ids = []
    etcd.get("/clusters/#{cluster_id}/nodes").children.each do |node|
      node_ids << node.key.split('/')[-1]
    end
    node_ids
  end

  def load_definitions(cluster_id)
    definitions = etcd.get(
      "/clusters/#{cluster_id}/definitions/data"
    ).value
    Tendrl.cluster_definitions = YAML.load(definitions)
  end

  def load_stats(clusters)
    stats = []
    unless monitoring.nil?
      cluster_ids = clusters.map{|e| e['cluster_id'] }
      stats = @monitoring.cluster_stats(cluster_ids)
      stats.each do |stat|
        cluster = clusters.find{|e| e['cluster_id'] == stat['id'] }
        next if cluster.nil?
        cluster['stats'] = stat['summary']
      end
    end
    clusters
  end


end
