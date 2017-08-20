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

  def app
    described_class
  end
end

def stub_definitions
  stub_request(
    :get,
    "http://127.0.0.1:4001/v2/keys/_NS/node_agent/compiled_definitions/data"
  ).
  to_return(
    status: 200,
    body: File.read(
      'spec/fixtures/definitions/tendrl_definitions_node_agent.json'
    )
  )
end

def stub_cluster_definitions(type='gluster')
  stub_request(
    :get,
    "http://127.0.0.1:4001/v2/keys/clusters/6b4b84e0-17b3-4543-af9f-e42000c52bfc/_NS/definitions/data"
  ).
  to_return(
    status: 200,
    body: File.read(
      "spec/fixtures/definitions/#{type}_definitions.json"
    )
  )
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

def stub_detected_cluster
  stub_request(
    :get,
    /http:\/\/127.0.0.1:4001\/v2\/keys\/nodes\/.*\/DetectedCluster\/detected_cluster_id/).
  to_return(
    status: 200,
    body: File.read(
      'spec/fixtures/detected_cluster.json'  
    )
  )
end

def stub_clusters(recursive=true)
  stub_request(
    :get,
    "http://127.0.0.1:4001/v2/keys/clusters?recursive=#{recursive}"
  ).
  to_return(
    :status => 200,
    :body => File.read(
      'spec/fixtures/clusters.json'
    )
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
  stub_request(
    :get,
    /http:\/\/127.0.0.1:4001\/v2\/keys\/queue\/.*/
  ).
  to_return(
    :status => 200,
    :body => File.read(
      'spec/fixtures/job.json'
    )
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
  attributes.each do |key, value|
    stub_request(
      :put,
      "http://127.0.0.1:4001/v2/keys/_tendrl/users/thardy/#{key}"
    ).
    to_return(
      :status => 200,
      :body => "{\"action\":\"set\",\"node\":{\"key\":\"/_tendrl/users/anivargi/#{key}\",\"value\":\"#{CGI.unescape(value)}\",\"modifiedIndex\":184,\"createdIndex\":184}}"
    )
  end
end

def stub_users
  stub_request(
    :get,
    "http://127.0.0.1:4001/v2/keys/_tendrl/users?recursive=true"
  ).
  to_return(
    :status => 200,
    :body => File.read('spec/fixtures/users.json')
  )
end

def stub_user(username)
  stub_request(
    :get,
    "http://127.0.0.1:4001/v2/keys/_tendrl/users/#{username}"
  ).
  to_return(
    :status => 200,
    :body => File.read('spec/fixtures/user.json')
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
    :headers => {}
  )
end

def stub_access_token
  stub_request(
    :get,
    "http://127.0.0.1:4001/v2/keys/_tendrl/access_tokens/d03ebb195dbe6385a7caeda699f9930ff2e49f29c381ed82dc95aa642a7660b8").
    to_return(
      :status => 200,
      :body => File.read('spec/fixtures/access_token.json')
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


