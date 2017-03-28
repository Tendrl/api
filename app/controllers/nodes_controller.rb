class NodesController < AuthenticatedUsersController

  before do
    definitions = etcd.get('/_NS/node_agent/compiled_definitions/data').value
    Tendrl.node_definitions = YAML.load(definitions)
  end

  get '/Flows' do
    flows = Tendrl::Flow.find_all
    { flows: flows }.to_json
  end

  get '/GetNodeList' do
    nodes = []
    existing_cluster_ids = []
    
    begin
      etcd.get('/nodes', recursive: true).children.each do |node|
        nodes << recurse(node)
      end
    rescue Etcd::KeyNotFound
    end

    begin
      etcd.get('/clusters', recursive: false).children.each do |c|
        existing_cluster_ids << c.key.split('/')[-1]
      end
    rescue Etcd::KeyNotFound
    end

    nodes, clusters = NodePresenter.list(nodes, existing_cluster_ids)
    nodes = load_stats(nodes)

    { nodes: nodes, clusters: clusters }.to_json
  end

  post '/ImportCluster' do
    flow = Tendrl::Flow.new('namespace.tendrl', 'ImportCluster')
    body = JSON.parse(request.body.read)

    # ImportCluster job structure:
    #
    # job = {
    #   "integration_id": "9a4b84e0-17b3-4543-af9f-e42000c52bfc",
    #   "run": "tendrl.node_agent.flows.import_cluster.ImportCluster",
    #   "status": "new",
    #   "type": "node",
    #   "node_ids": ["3943fab1-9ed2-4eb6-8121-5a69499c4568"],
    #   "parameters": {
    #     "TendrlContext.integration_id": "6b4b84e0-17b3-4543-af9f-e42000c52bfc",
    #     "Node[]": ["3943fab1-9ed2-4eb6-8121-5a69499c4568"],
    #     "DetectedCluster.sds_pkg_name": "gluster"
    #   }
    # }
    #
    # Values sent by the UI:
    #
    # {
    #   cluster_id: "c221ccdb-51d6-4b57-9f10-bcf30c7fa351"
    #   hosts: [
    #     {
    #       name: "dhcp43-203.lab.eng.blr.redhat.com",
    #       release: "ceph 10.2.5",
    #       role: "Monitor"
    #     }
    #   ],
    #   node_ids: ["3b6eb27f-3e83-4751-9d45-85a989ae2b25"],
    #   sds_type: "ceph",
    #   sds_name: "ceph 10.2.5"
    #   sds_version: "10.2.5"
    # }

    # TODO: UI should be sending the parameters as defined in the flows, API
    # shouldn't be translating.

    missing_params = []
    ['sds_type', 'node_ids'].each do |param|
      missing_params << param unless body[param] and not body[param].empty?
    end
    halt 401, { errors: { missing: missing_params } } unless missing_params.empty?

    node_ids = body['node_ids']
    halt 401, { errors: { message: "'node_ids' must be an array with values" } } unless node_ids.kind_of?(Array) and not node_ids.empty?

    body['DetectedCluster.sds_pkg_name'] = body['sds_type']
    body['Node[]'] = node_ids
    job = Tendrl::Job.new(current_user, flow).create(body, node_ids)
    status 202
    { job_id: job.job_id }.to_json
  end

  private

  def load_stats(nodes)
    stats = []
    unless monitoring.nil?
      node_ids = nodes.map{|n| n['node_id'] } 
      stats = @monitoring.node_stats(node_ids)
      stats.each do |stat|
        node = nodes.find{|e| e['node_id'] == stat['node_id'] }
        next if node.nil?
        node[:stats] = stat
      end
    end
    nodes
  end

end
