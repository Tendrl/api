class ClustersController < AuthenticatedUsersController

  get '/clusters' do
    clusters = Tendrl::Cluster.all
    { clusters: ClusterPresenter.list(clusters) }.to_json
  end

  get '/clusters/:cluster_id/nodes' do
    nodes = Tendrl::Node.find_all_by_cluster_id(params[:cluster_id])
    { nodes: NodePresenter.list(nodes) }.to_json
  end

  get '/clusters/:cluster_id/nodes/:node_id/bricks' do
    node = Tendrl::Node.find_by_cluster_id(params[:cluster_id], params[:node_id])
    halt 404 if node.nil?
    bricks = Tendrl::Brick.find_all_by_cluster_id_and_node_fqdn(
      params[:cluster_id], node['fqdn']
    )
    { bricks: BrickPresenter.list(bricks) }.to_json
  end

  get '/clusters/:cluster_id/volumes' do
    volumes = Tendrl::Volume.find_all_by_cluster_id(params[:cluster_id])
    { volumes: VolumePresenter.list(volumes) }.to_json
  end

  get '/clusters/:cluster_id/volumes/:volume_id/bricks' do
    references = Tendrl::Brick.find_refs_by_cluster_id_and_volume_id(
      params[:cluster_id], params[:volume_id]
    )
    bricks = Tendrl::Brick.find_by_cluster_id_and_refs(params[:cluster_id], references)
    { bricks: BrickPresenter.list(bricks) }.to_json
  end

  post '/clusters/:cluster_id/import' do
    load_node_definitions
    flow = Tendrl::Flow.new('namespace.tendrl', 'ImportCluster')
    body = JSON.parse(request.body.read)
    body['Cluster.enable_volume_profiling'] = if ['yes', 'no'].include?(body['enable_volume_profiling'])
                                                body['enable_volume_profiling']
                                              else
                                                'yes'
                                              end
    job = Tendrl::Job.new(
      current_user,
      flow,
      integration_id: params[:cluster_id]).create(body)
    status 202
    { job_id: job.job_id }.to_json
  end

  put '/clusters/:cluster_id/profiling' do
    cluster = Tendrl::Cluster.find(params[:cluster_id])
    body = JSON.parse(request.body.read)
    enable_volume_profiling = if ['yes', 'no'].include?(body['enable_volume_profiling'])
                                 body['enable_volume_profiling']
                              else
                                'yes'
                              end

    cluster.update_attributes(enable_volume_profiling: enable_volume_profiling)
    status 200
    ClusterPresenter.single(
      { params[:cluster_id] => cluster.attributes }
    ).to_json
  end

  private

  def cluster(cluster_id)
    load_definitions(cluster_id)
    @cluster ||= Tendrl.recurse(
      etcd.get("/clusters/#{cluster_id}/TendrlContext")
    )['tendrlcontext']
  rescue Etcd::KeyNotFound => e
    exception =  Tendrl::HttpResponseErrorHandler.new(
      e, cause: '/clusters/id', object_id: cluster_id
    )
    halt exception.status, exception.body.to_json
  end

  def load_definitions(cluster_id)
    definitions = etcd.get(
      "/clusters/#{cluster_id}/_NS/definitions/data"
    ).value
    Tendrl.cluster_definitions = YAML.load(definitions)
  rescue Etcd::KeyNotFound => e
    exception = Tendrl::HttpResponseErrorHandler.new(
      e, cause: '/clusters/definitions', object_id: cluster_id
    )
    halt exception.status, exception.body.to_json
  end

  def load_node_definitions
    definitions = etcd.get('/_NS/node_agent/compiled_definitions/data').value
    Tendrl.node_definitions = YAML.load(definitions)
  end

end
