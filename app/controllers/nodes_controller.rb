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
    flow = Tendrl::Flow.new('namespace.tendrl.node_agent', 'ImportCluster')
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

  post '/CreateCluster' do
    flow = Tendrl::Flow.new('namespace.tendrl', 'CreateCluster')
    body = JSON.parse(request.body.read)

    # Ceph CreateCluster example
    #
    # {
    #   "sds_type": "ceph",
    #   "sds_version": "10.2.5",
    #   "sds_parameters": {
    #     "name": "MyCluster",
    #     "fsid": "140cd3d5-58e4-4935-a954-d946ceff371d",
    #     "public_network": "192.168.128.0/24",
    #     "cluster_network": "192.168.220.0/24",
    #     "ceph_conf_overrides": {
    #       "global": {
    #         "osd_pool_default_pg_num": 128,
    #         "pool_default_pgp_num": 1
    #       }
    #     }
    #   },
    #   "node_identifier": "ip",
    #   "node_configuration": {
    #     "10.0.0.24": {
    #       "role": "ceph/mon",
    #       "provisioning_ip": "10.0.0.24",
    #       "monitor_interface": "eth0"
    #     },
    #     "10.0.0.29": {
    #       "role": "ceph/osd",
    #       "provisioning_ip": "10.0.0.29",
    #       "journal_size": 5192,
    #       "journal_colocation": "false",
    #       "storage_disks": [
    #         {
    #           "device": "/dev/sda",
    #           "journal": "/dev/sdc"
    #         },
    #         {
    #           "device": "/dev/sdb",
    #           "journal": "/dev/sdc"
    #         }
    #       ]
    #     },
    #     "10.0.0.30": {
    #       "role": "ceph/osd",
    #       "provisioning_ip": "10.0.0.30",
    #       "journal_colocation": "true",
    #       "storage_disks": [
    #         {
    #           "device": "/dev/sda"
    #         },
    #         {
    #           "device": "/dev/sdb"
    #         }
    #       ]
    #     }
    #   }
    # }
    #
    # Job structure:
    #
    # {
    #   "integration_id": "9a4b84e0-17b3-4543-af9f-e42000c52bfc",
    #   "run": "tendrl.flows.CreateCluster",
    #   "status": "new",
    #   "type": "node",
    #   "node_ids": [],
    #   "tags": ["provisioner/ceph"],
    #   "parameters": {
    #     "sds_type": "ceph",
    #     "sds_version": "10.2.5",
    #     "name": "MyCluster",
    #     "TendrlContext.integration_id": "9a4b84e0-17b3-4543-af9f-e42000c52bfc",
    #     "Node[]": [
    #       "3a95fd96-876d-439a-a64d-70332c069aaa",
    #       "3943fab1-9ed2-4eb6-8121-5a69499c4568",
    #       "b10e00e9-e444-41c2-9517-df2118b42731"
    #     ],
    #     "fsid": "140cd3d5-58e4-4935-a954-d946ceff371d",
    #     "public_network": "192.168.128.0/24",
    #     "cluster_network": "192.168.220.0/24",
    #     "ceph_conf_overrides": {
    #       "global": {
    #         "osd_pool_default_pg_num": 128,
    #         "pool_default_pgp_num": 1
    #       }
    #     },
    #     "node_configuration": {
    #       "3a95fd96-876d-439a-a64d-70332c069aaa": {
    #         "role": "ceph/mon",
    #         "provisioning_ip": "10.0.0.24",
    #         "monitor_interface": "eth0"
    #       },
    #       "3943fab1-9ed2-4eb6-8121-5a69499c4568": {
    #         "role": "ceph/osd",
    #         "provisioning_ip": "10.0.0.29",
    #         "journal_size": 5192,
    #         "journal_colocation": "false",
    #         "storage_disks": [
    #           {
    #             "device": "/dev/sda",
    #             "journal": "/dev/sdc"
    #           },
    #           {
    #             "device": "/dev/sdb",
    #             "journal": "/dev/sdc"
    #           }
    #         ]
    #       },
    #       "b10e00e9-e444-41c2-9517-df2118b42731": {
    #         "role": "ceph/osd",
    #         "provisioning_ip": "10.0.0.30",
    #         "journal_colocation": "true",
    #         "storage_disks": [
    #           {
    #             "device": "/dev/sda"
    #           },
    #           {
    #             "device": "/dev/sdb"
    #           }
    #         ]
    #       }
    #     }
    #   }
    # }

    missing_params = []
    ['sds_type', 'node_configuration'].each do |param|
      missing_params << param unless body[param] and not body[param].empty?
    end
    halt 401, { errors: { missing: missing_params } } unless missing_params.empty?

    # Check that the list of nodes is valid
    node_identifier = body['node_identifier']

    halt 401, { errors: { invalid: "'node_identifier', if specified, must be either 'uuid' or 'ip', provided: '#{node_identifier}'." } } \
      if node_identifier and \
        not ['uuid','ip'].include? node_identifier

    nodes = {}
    node_ids = body['node_configuration'].keys

    unavailable_nodes = []
    node_ids.each do |node_id|
      node = case node_identifier
             when 'ip'
               Tendrl::Node.find_by_ip(node_ip)
             when 'uuid'
               Tendrl::Node.new(uuid)
             end

      if node.nil? or not node.exist?
        unavailable_nodes << node_id
        next
      end

      nodes[node.uuid] = body['node_configuration'][node_id]
    end

    halt 404, { errors: { missing: "Unavailable nodes: #{unavailable_nodes.join(', ')}." } } unless unavailable_nodes.empty?

    parameters = {}
    parameters.merge! body['sds_parameters']
    ['sds_type','sds_version','name'].each do |param|
      parameters[param] = body[param] unless body[param].nil?
    end
    parameters['node_configuration'] = nodes
    parameters['Node[]'] = nodes.keys

    job = Tendrl::Job.new(current_user, Tendrl::Flow.new('tendrl', 'CreateCluster')).create(body, tags: ['provisioner/ceph'])
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
