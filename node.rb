require './base'
class Node < Base

  before do
    definitions = etcd.get('/_tendrl/definitions/master').value
    Tendrl.node_definitions = YAML.load(definitions)
  end

  get '/Flows' do
    flows = Tendrl::Flow.find_all
    { flows: flows }.to_json
  end

  get '/GetNodeList' do
    nodes = []
    existing_cluster_ids = []

    etcd.get('/nodes', recursive: true).children.each do |node|
      nodes << recurse(node)
    end

    etcd.get('/clusters').children.each do |c|
      existing_cluster_ids << c.key.split('/')[-1]
    end

    nodes, clusters = NodePresenter.list(nodes, existing_cluster_ids) 
    nodes = load_stats(nodes)

    { nodes: nodes, clusters: clusters }.to_json
  end

  post '/:flow' do
    flow = Tendrl::Flow.find_by_external_name_and_type(params[:flow], 'node')
    halt 404 if flow.nil?
    body = JSON.parse(request.body.read)
    body['TendrlContext.integration_id'] = SecureRandom.uuid
    job_id = SecureRandom.uuid
    job = etcd.set(
      "/queue/#{job_id}", 
      value: {
        integration_id: body['TendrlContext.integration_id'],
        job_id: job_id,
        status: 'new',
        parameters: body,
        run: flow.run,
        flow: flow.flow_name,
        type: 'node',
        created_from: 'API',
        created_at: Time.now.utc.iso8601
      }.
      to_json
    )
    status 202
    { job_id: job_id }.to_json
  end

  private

  def load_stats(nodes)
    stats = []
    unless monitoring.nil?
      node_ids = nodes.map{|n| n['node_id'] } 
      stats = @monitoring.node_stats(node_ids)
      stats.each do |stat|
        node = nodes.find{|e| e['node_id'] == stat['id'] }
        next if node.nil?
        node[:stats] = stat['summary']
      end
    end
    nodes
  end


end
