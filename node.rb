require './base'
class Node < Base

  
  before do
    definitions = etcd.get('/tendrl_definitions_node_agent/data').value
    Tendrl.node_definitions = YAML.load(definitions)
  end

  get '/Flows' do
    flows = Tendrl::Flow.find_all
    flows.to_json
  end

  get '/GetNodeList' do
    nodes = []
    etcd.get('/nodes').children.each do |node|
      node_attrs = {}
      etcd.get("#{node.key}/Node_context").children.each do |child|
        node_attrs[child.key.split("#{node.key}/Node_context/")[1]] = child.value
      end
      nodes << node_attrs
    end
    nodes.to_json
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

end
