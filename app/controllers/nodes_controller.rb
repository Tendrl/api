class NodesController < AuthenticatedUsersController

  before do
    definitions = etcd.get('/_NS/node_agent/compiled_definitions/data').value
    Tendrl.node_definitions = YAML.load(definitions)
  end

  get '/Flows' do
    flows = Tendrl::Flow.find_all
    { flows: flows }.to_json
  end

  get '/nodes' do
    begin
      nodes = etcd.get('/nodes', recursive: true).children.map do |node|
        Tendrl.recurse(node)
      end
    rescue Etcd::KeyNotFound
    end

    nodes = NodePresenter.list(nodes)

    { nodes: nodes }.to_json
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
    halt 422, { errors: { missing: missing_params } }.to_json unless missing_params.empty?

    node_ids = body['node_ids']
    halt 422, { errors: { message: "'node_ids' must be an array with values" } }.to_json unless node_ids.kind_of?(Array) and not node_ids.empty?
    detected_cluster_id = detected_cluster_id(node_ids.first)
    halt 422, { errors: { message: "Node #{node_ids.first} not found" } }.to_json if detected_cluster_id.nil?

    body['DetectedCluster.detected_cluster_id'] = detected_cluster_id
    body['DetectedCluster.sds_pkg_name'] = body['sds_type']
    body['Node[]'] = node_ids
    job = Tendrl::Job.new(current_user, flow).create(body)

    status 202
    { job_id: job.job_id }.to_json
  end

  post '/CreateCluster' do
    flow = Tendrl::Flow.new('namespace.tendrl', 'CreateCluster')
    body = JSON.parse(request.body.read)

    # Ceph CreateCluster example
    #
    # {
    #   "sds_name": "ceph",
    #   "sds_version": "10.2.5",
    #   "sds_parameters": {
    #     "name": "MyCluster",
    #     "cluster_id": "140cd3d5-58e4-4935-a954-d946ceff371d",
    #     "public_network": "192.168.128.0/24",
    #     "cluster_network": "192.168.220.0/24",
    #     "conf_overrides": {
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
    #     "TendrlContext.sds_name": "ceph",
    #     "TendrlContext.sds_version": "10.2.5",
    #     "TendrlContext.cluster_name": "MyCluster",
    #     "TendrlContext.cluster_id": "9a4b84e0-17b3-4543-af9f-e42000c52bfc",
    #     "Node[]": [
    #       "3a95fd96-876d-439a-a64d-70332c069aaa",
    #       "3943fab1-9ed2-4eb6-8121-5a69499c4568",
    #       "b10e00e9-e444-41c2-9517-df2118b42731"
    #     ],
    #     "Cluster.public_network": "192.168.128.0/24",
    #     "Cluster.cluster_network": "192.168.220.0/24",
    #     "Cluster.conf_overrides": {
    #       "global": {
    #         "osd_pool_default_pg_num": 128,
    #         "pool_default_pgp_num": 1
    #       }
    #     },
    #     "Cluster.node_configuration": {
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
    ['sds_name', 'node_configuration'].each do |param|
      missing_params << param unless body[param] and not body[param].empty?
    end
    halt 422, { errors: { missing: missing_params } }.to_json unless missing_params.empty?

    node_identifier = body['node_identifier']
    halt 422, { errors: { invalid: "'node_identifier', if specified, must be either 'uuid' or 'ip', provided: '#{node_identifier}'." } }.to_json \
      if node_identifier and \
        not ['uuid','ip'].include? node_identifier

    nodes = {}
    node_ids = body['node_configuration'].keys

    unavailable_nodes = []
    node_ids.each do |node_id|
      node = case node_identifier
             when 'ip'
               Tendrl::Node.find_by_ip(node_id)
             when 'uuid'
               Tendrl::Node.new(uuid)
             end

      if node.nil? or not node.exist?
        unavailable_nodes << node_id
        next
      end

      nodes[node.uuid] = body['node_configuration'][node_id]
    end

    halt 422, { errors: { missing: "Unavailable nodes: #{unavailable_nodes.join(', ')}." } }.to_json unless unavailable_nodes.empty?

    parameters = {}
    ['sds_name', 'sds_version'].each do |param|
      parameters["TendrlContext.#{param}"] = body[param]
    end
    parameters['TendrlContext.cluster_name'] = body['sds_parameters']['name']
    parameters['TendrlContext.cluster_id'] =  body['sds_parameters']['cluster_id']

    parameters['Node[]'] = nodes.keys

    ['public_network', 'cluster_network', 'conf_overrides'].each do |param|
      if body['sds_parameters']["#{param}"].present?
        parameters["Cluster.#{param}"] = body['sds_parameters']["#{param}"]
      end
    end
    parameters['Cluster.node_configuration'] = nodes

    job = Tendrl::Job.new(current_user, flow).create(parameters)
    status 202
    { job_id: job.job_id }.to_json
    end

    # Sample job structure

    # {
    #   "run": "tendrl.flows.ExpandCluster",
    #   "type": "node",
    #   "created_from": "API",
    #   "created_at": "2017-03-09T14:15:14Z",
    #   "username": "admin",
    #   "parameters": {
    #     "Node[]": ["867d6aae-fb98-4060-9f6a-1da4e4988db8"],
    #     "Cluster.node_configuration": {
    #       "867d6aae-fb98-4060-9f6a-1da4e4988db8": {
    #         "role": "glusterfs/node",
    #         "provisioning_ip": "10.70.43.222",
    #       },
    #     },
    #     "TendrlContext.sds_name": "gluster",
    #     "TendrlContext.integration_id": "d3c644f1-0f94-43e1-946f-e40c4694d703"
    #   },
    #   "tags":["provisioner/d3c644f1-0f94-43e1-946f-e40c4694d703"],
    # }

    put '/:cluster_id/ExpandCluster' do
      flow = Tendrl::Flow.new('namespace.tendrl', 'ExpandCluster')
      halt 404 if flow.nil?
      body = JSON.parse(request.body.read)
      missing_params = []

      ['sds_name', 'Cluster.node_configuration'].each do |param|
        missing_params << param unless body[param] and not body[param].empty?
      end
      halt 422, { errors: { missing: missing_params } }.to_json unless missing_params.empty?

      ['sds_name'].each do |param|
        body["TendrlContext.#{param}"] = body.delete('sds_name')
      end

      body['Node[]'] = body['Cluster.node_configuration'].keys

      job = Tendrl::Job.new(
        current_user,
        flow, 
        integration_id: params[:cluster_id]
      ).create(body)

      status 202
      { job_id: job.job_id }.to_json
    end

    post '/:flow' do
      flow = Tendrl::Flow.find_by_external_name_and_type(
        params[:flow], 'node_agent'
      )
      halt 404 if flow.nil?
      body = JSON.parse(request.body.read)
      job = Tendrl::Job.new(current_user, flow).create(body)

      status 202
      { job_id: job.job_id }.to_json
    end


    private

    def detected_cluster_id(node_id)
      Tendrl.etcd.get("/nodes/#{node_id}/DetectedCluster/detected_cluster_id").value
    rescue Etcd::KeyNotFound
      nil
    end

  end
