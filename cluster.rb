require './base'

class Cluster < Base

  get '/GetClusterList' do
    clusters = []
    cluster_ids = []
    etcd.get('/clusters', recursive: true).children.each do |cluster|
      cluster_ids << cluster.key.split('/')[-1]
      clusters << recurse(cluster) 
    end
    clusters = load_stats(clusters)
    { clusters: clusters }.to_json
  end

  get '/:cluster_id/Flows' do
    halt 404 if cluster(params[:cluster_id]).nil?
    flows = Tendrl::Flow.find_all
    flows.to_json
  end

  get %r{\/([a-zA-Z0-9-]+)\/Get(\w+)List} do |cluster_id, object_name|
    halt 404 if cluster(cluster_id).nil?
    objects = []
    etcd.get(
      "#{@cluster.key}/#{object_name.pluralize}", recursive: true
    ).children.each do |node|
      objects << recurse(node)
    end
    objects.to_json
  end

  post '/:cluster_id/:flow' do
    halt 404 if cluster(params[:cluster_id]).nil?
    flow = Tendrl::Flow.find_by_external_name_and_type(
      params[:flow], 'cluster'
    )
    raise Sinatra::NotFound if flow.nil?
    body = JSON.parse(request.body.read)
    job_id = SecureRandom.hex
    tendrl_context = context(params[:cluster_id])
    job = etcd.set(
      "/queue/#{job_id}", 
      value: {
        cluster_id: params[:cluster_id],
        status: 'new',
        parameters: body.merge(tendrl_context),
        run: flow.run,
        type: 'sds',
        created_from: 'API'
      }.
      to_json
    )
    status 202
    { job_id: job_id }.to_json
  end

  delete '/:cluster_id/:flow' do
    halt 404 if cluster(params[:cluster_id]).nil?
    flow = Tendrl::Flow.find_by_external_name_and_type(
      params[:flow], 'cluster'
    )
    halt 404 if flow.nil?
    body = JSON.parse(request.body.read)
    job_id = SecureRandom.hex
    tendrl_context = context(params[:cluster_id])
    job = etcd.set(
      "/queue/#{job_id}", 
      value: {
        cluster_id: params[:cluster_id],
        status: 'new',
        parameters: body.merge(tendrl_context),
        run: flow.run,
        type: 'sds',
        created_from: 'API'
      }.
      to_json
    )
    status 202
    { job_id: job_id }.to_json
  end

  private

  def context(cluster_id)
    tendrl_context = "#{@cluster.key}/Tendrl_context"
    attrs = recurse(etcd.get(tendrl_context))
    {
      'Tendrl_context.sds_name' => attrs['sds_name'],
      'Tendrl_context.sds_version' => attrs['sds_version'],
      'Tendrl_context.cluster_id' => attrs['cluster_id']
    }
  end

  def cluster(cluster_id)
    begin
      @cluster ||= etcd.get("/clusters/#{cluster_id}")
      load_definitions(cluster_id)
    rescue Etcd::KeyNotFound
      nil
    end
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
      cluster_ids = clusters.map{|e| e.keys.first }
      stats = @monitoring.cluster_stats(cluster_ids)
      stats.each do |stat|
        cluster = clusters.find{|e| e.keys.first == stat['id'] }
        next if cluster.nil?
        cluster[:stats] = stat['summary']
      end
    end
    clusters
  end


end
