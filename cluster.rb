require './base'

class Cluster < Base

  get '/GetClusterList' do
    clusters = []
    etcd.get('/clusters', recursive: true).children.each do |cluster|
      clusters << recurse(cluster) 
    end
    clusters = ClusterPresenter.list(clusters)
    clusters = load_stats(clusters)
    { clusters: clusters }.to_json
  end

  get '/:cluster_id/Flows' do
    cluster = cluster(params[:cluster_id])
    load_definitions(cluster['sds_name'])
    flows = Tendrl::Flow.find_all
    flows.to_json
  end

  get %r{\/([a-zA-Z0-9-]+)\/Get(\w+)List} do |cluster_id, object_name|
    cluster = cluster(cluster_id)
    objects = []
    etcd.get(
      "/clusters/#{cluster['integration_id']}/#{object_name.pluralize}", recursive: true
    ).children.each do |node|
      objects << recurse(node)
    end
    objects.to_json
  end

  post '/:cluster_id/:flow' do
    flow = Tendrl::Flow.find_by_external_name_and_type(
      params[:flow], 'cluster'
    )
    halt 404 if flow.nil?
    cluster = cluster(params[:cluster_id])
    body = JSON.parse(request.body.read)
    job_id = SecureRandom.uuid
    job = etcd.set(
      "/queue/#{job_id}", 
      value: {
        integration_id: params[:cluster_id],
        job_id: job_id,
        status: 'new',
        parameters: body.merge(cluster),
        run: flow.run,
        type: 'sds',
        created_from: 'API',
        created_at: Time.now.utc.iso8601
      }.
      to_json
    )
    status 202
    { job_id: job_id }.to_json
  end

  delete '/:cluster_id/:flow' do
    flow = Tendrl::Flow.find_by_external_name_and_type(
      params[:flow], 'cluster'
    )
    halt 404 if flow.nil?
    cluster = cluster(params[:cluster_id])
    body = JSON.parse(request.body.read)
    job_id = SecureRandom.uuid
    job = etcd.set(
      "/queue/#{job_id}", 
      value: {
        integration_id: params[:cluster_id],
        job_id: job_id,
        status: 'new',
        parameters: body.merge(cluster),
        run: flow.run,
        type: 'sds',
        created_from: 'API',
        created_at: Time.now.utc.iso8601
      }.
      to_json
    )
    status 202
    { job_id: job_id }.to_json
  end

  private

  def cluster(cluster_id)
    @cluster ||=
      recurse(etcd.get("/clusters/#{cluster_id}/TendrlContext"))['tendrlcontext']
  end

  def load_definitions(sds_name)
    definitions = etcd.get(
      "/_tendrl/definitions/#{sds_name}"
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
