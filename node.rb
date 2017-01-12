require './base'
class Node < Base

  
  before do
    definitions = etcd.get('/tendrl_definitions_node_agent/data').value
    Tendrl.node_definitions = YAML.load(definitions)
  end

  get '/Flows' do
    flows = Tendrl::Flow.find_all
    { flows: flows }.to_json
  end

  get '/GetNodeList' do
    nodes = []
    node_ids = []
    etcd.get('/nodes', recursive: true).children.each do |node|
      nodes << recurse(node)
    end
    nodes, clusters = NodePresenter.list(nodes) 
    nodes = load_stats(nodes)
    { nodes: nodes, clusters: clusters }.to_json
  end

  post '/:flow' do
    flow = Tendrl::Flow.find_by_external_name_and_type(params[:flow], 'node')
    halt 404 if flow.nil?
    body = JSON.parse(request.body.read)
    body['Tendrl_context.cluster_id'] = SecureRandom.uuid
    job_id = SecureRandom.hex
    job = etcd.set(
      "/queue/#{job_id}", 
      value: {
        cluster_id: body['Tendrl_context.cluster_id'],
        status: 'new',
        parameters: body,
        run: flow.run,
        type: 'node',
        created_from: 'API'
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
