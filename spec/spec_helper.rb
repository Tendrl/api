ENV['RACK_ENV'] = 'test'

require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
end

require './lib/tendrl'
require './app/controllers/application_controller'
require './app/controllers/authenticated_users_controller'
require 'webmock/rspec'

WebMock.disable_net_connect!(allow_localhost: false)

RSpec.configure do |config|
  include Rack::Test::Methods

  config.filter_run_when_matching :focus

  def app
    described_class
  end

  config.before(:each) do
    $etcd_client = $etcd_client.dup
    allow(Tendrl.etcd).to receive(:get).and_call_original
  end
end

def stub_definitions
  defs = YAML.load_file 'spec/fixtures/definitions/tendrl_definitions_node_agent.yaml'
  allow(Tendrl).to receive(:load_node_definitions).and_return(defs)
  allow(Tendrl).to receive(:node_definitions).and_return(defs)
  allow(Tendrl).to receive(:current_definitions).and_return(defs)
end

def stub_cluster_definitions(type='gluster')
  defs = YAML.load_file "spec/fixtures/definitions/#{type}.yaml"
  allow(Tendrl).to receive(:load_definitions).and_return(defs)
  allow(Tendrl).to receive(:cluster_definitions).with('6b4b84e0-17b3-4543-af9f-e42000c52bfc').and_return(defs)
  allow(Tendrl).to receive(:current_definitions).and_return(defs)
end

def stub_nodes
  stub_request(
    :get,
    "http://127.0.0.1:4001/v2/keys/nodes?recursive=true"
  ).
  to_return(
    :status => 200,
    :body => File.read(
      'spec/fixtures/nodes.json'
    )
  )
end

def stub_clusters(recursive=true)
  allow(Tendrl.etcd).to receive(:get).with('/clusters', recursive: true).and_return(
    YAML.load_file('spec/fixtures/clusters.yml')
  )
end

def stub_cluster_context
  stub_request(
    :get,
    /http:\/\/127.0.0.1:4001\/v2\/keys\/clusters\/.*\/TendrlContext/i
  ).
  to_return(
    :status => 200,
    body: File.read('spec/fixtures/cluster_context.json')
  )
end

def stub_cluster
  stub_request(
    :get,
    'http://127.0.0.1:4001/v2/keys/clusters/6b4b84e0-17b3-4543-af9f-e42000c52bfc?recursive=true'
  ).
  to_return(
    :status => 200,
    :body => File.read('spec/fixtures/cluster.json')
  )
end

def stub_unmanaged_cluster
  stub_request(
    :get,
    'http://127.0.0.1:4001/v2/keys/clusters/6b4b84e0-17b3-4543-af9f-e42000c52bfc'
  ).
  to_return(
    :status => 200,
    body: File.read('spec/fixtures/unmanaged_clusters.json')
  )
end

def stub_managed_cluster
  stub_request(
    :get,
    'http://127.0.0.1:4001/v2/keys/clusters/6b4b84e0-17b3-4543-af9f-e42000c52bfc'
  ).
  to_return(
    :status => 200,
    body: File.read('spec/fixtures/managed_clusters.json')
  )
end

def stub_cluster_profiling
  stub_request(
    :put,
    "http://127.0.0.1:4001/v2/keys/clusters/6b4b84e0-17b3-4543-af9f-e42000c52bfc/volume_profiling_flag").
    with(:body => "value=enable").
    to_return(:status => 200, :body => "{\"action\":\"set\",\"node\":{\"key\":\"/clusters/6b4b84e0-17b3-4543-af9f-e42000c52bfc/volume_profiling_flag\",\"value\":\"enable\",\"modifiedIndex\":441,\"createdIndex\":441}}")
  end

def stub_job_creation
  stub_request(
    :put,
    /http:\/\/127.0.0.1:4001\/v2\/keys\/queue\/.*/
  ).to_return(
    status: 200,
    body: File.read('spec/fixtures/job_created.json')
  )
end

def stub_pools
  stub_request(
    :get,
    /http:\/\/127.0.0.1:4001\/v2\/keys\/clusters\/.*\/Pools\?recursive=true/
  ).
  to_return(
    :status => 200,
    :body => File.read(
      'spec/fixtures/pools.json'
    )
  )
end

def stub_volumes
  stub_request(
    :get,
    /http:\/\/127.0.0.1:4001\/v2\/keys\/clusters\/.*\/Volumes\?recursive=true/
  ).
  to_return(
    :status => 200,
    :body => File.read(
      'spec/fixtures/volumes.json'
    )
  )
end

def stub_jobs
  stub_request(
    :get,
    "http://127.0.0.1:4001/v2/keys/queue?recursive=true"
  ).
  to_return(
    :status => 200,
    :body => File.read(
      'spec/fixtures/jobs.json'
    )
  )
end

def stub_job
  allow(Tendrl.etcd).to receive(:get).with('/queue/3d38fb70-6865-4d77-82e0-22509359efef', recursive: true).and_return(YAML.load_file('spec/fixtures/job.yml'))
end

def stub_unknown_cluster
  stub_request(
    :get,
    /http:\/\/127.0.0.1:4001\/v2\/keys\/clusters\/unknown/
  ).
  to_return(
    :status => 404,
    :body => {
      "errorCode" => 100,
      "message" =>  "Key not found",
      "cause" => "/clusters/unknown",
      "index"=> 51850
    }.to_json
  )
end

def stub_missing_job
  stub_request(
    :get,
    /http:\/\/127.0.0.1:4001\/v2\/keys\/queue\/missing/
  ).
  to_return(
    :status => 404,
    :body => {
      "errorCode" => 100,
      "message" =>  "Key not found",
      "cause" => "/queue/missing",
      "index"=> 51850
    }.to_json
  )
end

def stub_node_ids
  stub_request(
    :get,
    /http:\/\/127.0.0.1:4001\/v2\/keys\/clusters\/.*\/nodes/i
  ).
  to_return(
    :status => 200,
    :body => File.read(
      'spec/fixtures/node_ids.json'
    )
  )
end

def stub_create_user_attributes(attributes)
  attributes.merge!(
    password_hash: '$2a$10$d1L8axCcsr5XRMtzbNNuaOM5I6D9dKu0VJqifND/eHCnj8M1QkP1W',
    password_salt: '$2a$10$d1L8axCcsr5XRMtzbNNuaO'
  )
  stub_request(
    :put,
    "http://127.0.0.1:4001/v2/keys/_tendrl/users/#{attributes[:username]}/data"
  ).
  to_return(
    :status => 200,
    :body => "{\"action\":\"set\",\"node\":{\"key\":\"/_tendrl/users/#{attributes[:username]}/data\",\"value\":#{CGI.unescape(attributes.to_json.to_json)},\"modifiedIndex\":184,\"createdIndex\":184}}"
  )
end

def stub_update_user_attributes(username, attributes)
  attributes.each do |key, value|
    stub_request(
      :put,
      /http:\/\/127.0.0.1:4001\/v2\/keys\/_tendrl\/users\/#{username}\/.*/i
    ).
    to_return(
      :status => 200,
      :body => "{\"action\":\"set\",\"node\":{\"key\":\"/_tendrl/users/#{username}/#{key}\",\"value\":\"#{CGI.unescape(value.to_s)}\",\"modifiedIndex\":184,\"createdIndex\":184}}"
    )
  end
end

def stub_users
  allow(Tendrl.etcd).to receive(:get).with('/_tendrl/users', recursive: true).and_return(YAML.load_file('spec/fixtures/users.yml'))
end

def stub_user(username)
  stub_request(
    :get,
    "http://127.0.0.1:4001/v2/keys/_tendrl/users/#{username}"
  ).
  to_return(
    :status => 200,
    :body => File.read("spec/fixtures/#{username}.json")
  )
end

def stub_user_create(username)
 stub_request(
    :put,
    "http://127.0.0.1:4001/v2/keys/_tendrl/users/#{username}").
    with(
      :body => "dir=true"
 ).
  to_return(
    :status => 201,
    :body => "{\"action\":\"set\",\"node\":{\"key\":\"/_tendrl/users/#{username}\",\"dir\":true,\"modifiedIndex\":437,\"createdIndex\":437}}",
  )
end

def stub_create_existing_user(username)
  stub_request(
    :put,
    "http://127.0.0.1:4001/v2/keys/_tendrl/users/#{username}").
    with(
      :body => "dir=true"
  ).
  to_return(
    :status => 200,
    :body => "{\"action\":\"set\",\"node\":{\"key\":\"/_tendrl/users/#{username}\",\"dir\":true,\"modifiedIndex\":454,\"createdIndex\":454}}",
    :headers => {}
  )
end

def stub_failed_create_existing_user(username)
  stub_request(
    :put,
    "http://127.0.0.1:4001/v2/keys/_tendrl/users/#{username}").
    with(
      :body => "dir=true"
  ).
  to_return(
    :status => 403,
    :body => "{\"errorCode\":102,\"message\":\"Not a file\",\"cause\":\"/_tendrl/users/meh\",\"index\":453}",
    :headers => {}
  )
end

def stub_access_token(username)
  stub_request(
    :get,
    "http://127.0.0.1:4001/v2/keys/_tendrl/access_tokens/d03ebb195dbe6385a7caeda699f9930ff2e49f29c381ed82dc95aa642a7660b8").
    to_return(
      :status => 200,
      :body => "{\"action\": \"get\",\"node\": {\"key\": \"/_tendrl/access_tokens/8d6ff8e9475dcf9815c3adce4aa3f6b999c31d29281d0cb90fe085d589b4a736\",\"value\": \"#{username}\",\"modifiedIndex\": 342,\"createdIndex\": 342}}"
  )
end

def stub_delete_user(username)
  stub_request(
    :delete,
    "http://127.0.0.1:4001/v2/keys/_tendrl/users/#{username}?recursive=true").
  to_return(
    :status => 200,
    :body => "{\"action\":\"delete\",\"node\":{\"key\":\"/_tendrl/users/#{username}\",\"dir\":true,\"modifiedIndex\":455,\"createdIndex\":454},\"prevNode\":{\"key\":\"/_tendrl/users/fff\",\"dir\":true,\"modifiedIndex\":454,\"createdIndex\":454}}"
  )
end

def stub_email_notifications_index(username, email)
  stub_request(
    :put,
    "http://127.0.0.1:4001/v2/keys/_tendrl/indexes/notifications/email_notifications/#{username}").
  with(
    :body => "value=#{CGI.escape(email)}"
  ).
  to_return(
    :status => 200,
    :body => "{\"action\":\"get\",\"node\":{\"key\":\"/_tendrl/indexes/notifications/email_notifications\",\"dir\":true,\"nodes\":[{\"key\":\"/_tendrl/indexes/notifications/email_notifications/#{username}\",\"value\":\"#{email}\",\"modifiedIndex\":456,\"createdIndex\":456}],\"modifiedIndex\":456,\"createdIndex\":456}}"
  )
end

def stub_delete_email_notifications_index(username)
  stub_request(
    :delete,
    "http://127.0.0.1:4001/v2/keys/_tendrl/indexes/notifications/email_notifications/#{username}").
  to_return(
    :status => 200,
    :body => ""
  )
end

def stub_ip
  stub_request(
    :get,
    /http:\/\/127.0.0.1:4001\/v2\/keys\/indexes\/ip\/.*/i
  ).
  to_return(
    :status => 200, 
    :body => File.read('spec/fixtures/ip.json'),
  )
end

def stub_node
  stub_request(
    :get,
    /http:\/\/127.0.0.1:4001\/v2\/keys\/nodes\/.*/i
  ).
  to_return(
    :status => 200,
    :body => File.read('spec/fixtures/node.json')
    )
end
