ENV['RACK_ENV'] = 'test'

require_relative File.join('..', 'base')
require './lib/tendrl'
require './node'
require './cluster'

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
    "http://127.0.0.1:2379/v2/keys/_tendrl/definitions/master"
  ).
  to_return(
    status: 200,
    body: File.read(
      'spec/fixtures/definitions/tendrl_definitions_node_agent.json'
    )
  )
end

def stub_nodes
  stub_request(
    :get,
    "http://127.0.0.1:2379/v2/keys/nodes?recursive=true"
  ).
  to_return(
    :status => 200,
    :body => File.read(
      'spec/fixtures/nodes.json'
    )
  )
end

def stub_clusters(recursive=true)
  stub_request(
    :get,
    "http://127.0.0.1:2379/v2/keys/clusters?recursive=#{recursive}"
  ).
  to_return(
    :status => 200,
    :body => File.read(
      'spec/fixtures/clusters.json'
    )
  )
end

def stub_monitoring_config(status=200, file='monitoring_config.json')
  stub_request(
    :get,
    "http://127.0.0.1:2379/v2/keys/_tendrl/config/performance_monitoring/data"
  ).
  to_return(
    :status => status,
    :body => File.read("spec/fixtures/#{file}")
  )
end

def stub_node_monitoring
  stub_request(
    :get,
    /http:\/\/127.0.0.1:5000\/monitoring\/nodes\/summary\?node_ids=.*/
  ).
  to_return(
    status: 200,
    body: File.read('spec/fixtures/monitoring_node.json')
  )
end

def stub_cluster_monitoring
  stub_request(
    :get,
    /http:\/\/127.0.0.1:5000\/monitoring\/clusters\/summary\?cluster_ids=.*/
  ).
  to_return(
    status: 200,
    body: File.read('spec/fixtures/monitoring_cluster.json')
  )
end

def stub_cluster_context
  stub_request(
    :get,
    /http:\/\/127.0.0.1:2379\/v2\/keys\/clusters\/.*\/TendrlContext/i
  ).
  to_return(
    :status => 200,
    body: File.read('spec/fixtures/cluster_context.json')
  )
end

def stub_job_creation
  stub_request(
    :put,
    /http:\/\/127.0.0.1:2379\/v2\/keys\/queue\/.*/
  ).to_return(
    status: 200,
    body: File.read('spec/fixtures/job_created.json')
  )
end

def stub_pools
  stub_request(
    :get,
    /http:\/\/127.0.0.1:2379\/v2\/keys\/clusters\/.*\/Pools\?recursive=true/
  ).
  to_return(
    :status => 200,
    :body => File.read(
      'spec/fixtures/pools.json'
    )
  )
end

def stub_jobs
  stub_request(
    :get,
    "http://127.0.0.1:2379/v2/keys/queue?recursive=true"
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
    /http:\/\/127.0.0.1:2379\/v2\/keys\/queue\/.*/
  ).
  to_return(
    :status => 200,
    :body => File.read(
      'spec/fixtures/job.json'
    )
  )

end


