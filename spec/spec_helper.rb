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
    "http://127.0.0.1:2379/v2/keys/tendrl_definitions_node_agent/data"
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

def stub_clusters
  stub_request(
    :get,
    "http://127.0.0.1:2379/v2/keys/clusters?recursive=true"
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
    "http://127.0.0.1:2379/v2/keys/monitoring/config"
  ).
  to_return(
    :status => status,
    :body => File.read("spec/fixtures/#{file}")
  )
end

def stub_node_monitoring
  stub_request(
    :get,
    /http:\/\/127.0.0.1:9000\/monitoring\/nodes\/summary\?nodes=.*/
  ).
  to_return(
    status: 200,
    body: File.read('spec/fixtures/monitoring_node.json')
  )
 end

def stub_cluster_monitoring
 stub_request(
    :get,
    /http:\/\/127.0.0.1:9000\/monitoring\/clusters\/summary\?clusters=.*/
  ).
  to_return(
    status: 200,
    body: File.read('spec/fixtures/monitoring_cluster.json')
  )
end


