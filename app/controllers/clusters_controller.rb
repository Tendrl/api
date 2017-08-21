class ClustersController < AuthenticatedUsersController

  get '/clusters' do
    clusters = Tendrl::Cluster.all
    { clusters: ClusterPresenter.list(clusters) }.to_json
  end

  get '/clusters/:cluster_id/flows' do
    cluster = cluster(params[:cluster_id])
    flows = Tendrl::Flow.find_all
    flows.to_json
  end

  get %r{\/clusters\/([a-zA-Z0-9-]+)\/(\w+)} do |cluster_id, object_name|
    load_definitions(cluster_id)
    object = Tendrl::Object.find_by_object_name(object_name.singularize.capitalize)
    halt 404 if object.nil?
    cluster = cluster(cluster_id)
    objects = []
    begin
      etcd.get(
        "/clusters/#{cluster['integration_id']}/#{object_name.capitalize}",
        recursive: true
      ).children.each do |node|
        objects << Tendrl.recurse(node)
      end
    rescue Etcd::KeyNotFound, Etcd::NotDir

    end
    presenter = "#{object_name.singularize.downcase}_presenter"
      .classify
    if Object.const_defined?(presenter)
      presenter.constantize.list(objects).to_json
    else
      objects.to_json
    end
  end

  post '/clusters/:cluster_id/import' do
    load_node_definitions
    flow = Tendrl::Flow.new('namespace.tendrl', 'ImportCluster')
    body = JSON.parse(request.body.read)
    job = Tendrl::Job.new(
      current_user,
      flow,
      integration_id: params[:cluster_id]).create(body)
    status 202
    { job_id: job.job_id }.to_json
  end

  post '/clusters/:cluster_id/:flow' do
    cluster = cluster(params[:cluster_id])
    flow = Tendrl::Flow.find_by_external_name_and_type(
      params[:flow], 'cluster'
    )
    halt 404 if flow.nil?
    body = JSON.parse(request.body.read)
    job = Tendrl::Job.new(
      current_user,
      flow,
      type: 'sds',
      integration_id: params[:cluster_id]
    ).create(body)

    status 202
    { job_id: job.job_id }.to_json
  end

  put '/clusters/:cluster_id/profiling' do
    cluster = Tendrl::Cluster.find(params[:cluster_id])
    body = JSON.parse(request.body.read)
    cluster.update_attributes(
      enable_volume_profiling: body['enable_volume_profiling']
    )
    status 200
    ClusterPresenter.single({ params[:cluster_id] => cluster.attributes })
  end

  put '/clusters/:cluster_id/:flow' do
    cluster = cluster(params[:cluster_id])
    flow = Tendrl::Flow.find_by_external_name_and_type(
      params[:flow], 'cluster'
    )
    halt 404 if flow.nil?
    body = JSON.parse(request.body.read)

    job = Tendrl::Job.new(
      current_user,
      flow,
      type: 'sds',
      integration_id: params[:cluster_id]
    ).create(body)

    status 202
    { job_id: job.job_id }.to_json
  end

  delete '/clusters/:cluster_id/:flow' do
    cluster = cluster(params[:cluster_id])
    flow = Tendrl::Flow.find_by_external_name_and_type(
      params[:flow], 'cluster'
    )
    halt 404 if flow.nil?
    body = JSON.parse(request.body.read)

    job = Tendrl::Job.new(
      current_user,
      flow,
      type: 'sds',
      integration_id: params[:cluster_id]
    ).create(body)

    status 202
    { job_id: job.job_id }.to_json
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
