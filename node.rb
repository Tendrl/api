require './base'
class Node < Base

  before do
    definitions = etcd.get('/tendrl_definitions_node_agent/data').value
    Tendrl.node_definitions = YAML.load(definitions)
  end

  get '/Flows' do
    flows = Tendrl::Flow.find_all
    respond_to do |f|
      f.json { flows.to_json }
    end
  end

  get '/GetNodeList' do
    nodes = []
    etcd.get('/nodes').children.each do |node|
      node_attrs = {}
      etcd.get("#{node.key}/node_context").children.each do |child|
        node_attrs[child.key.split("#{node.key}/node_context/")[1]] = child.value
      end
      nodes << node_attrs
    end
    respond_to do |f|
      f.json { nodes.to_json }
    end
  end

  post '/:flow' do
    flow = Tendrl::Flow.find_by_external_name_and_type(params[:flow], 'node')
    raise Sinatra::NotFound if flow.nil?
    body = JSON.parse(request.body.read)
    body['Tendrl_context.cluster_id'] = SecureRandom.uuid
    job_id = SecureRandom.hex
    job = etcd.set(
      "/queue/#{job_id}", 
      value: {
        cluster_id: body['Tendrl_context.cluster_id'],
        status: 'processing',
        parameters: body,
        run: flow.run,
        type: 'node',
        created_from: 'API'
      }.
      to_json
    )
    respond_to do |f|
      status 202
      f.json { { job_id: job_id }.to_json }
    end
  end

end
