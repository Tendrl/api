require 'spec_helper'
require './app/controllers/nodes_controller'

describe NodesController do

  let(:http_env){
    {
      'HTTP_AUTHORIZATION' => 'Bearer d03ebb195dbe6385a7caeda699f9930ff2e49f29c381ed82dc95aa642a7660b8',
      'CONTENT_TYPE' => 'application/json'
    }
  }

  before do
    stub_user('dwarner')
    stub_access_token
    stub_definitions
  end

  it 'Flows' do
    get "/Flows",{}, http_env
    expect(last_response.status).to eq 200
  end

  context 'import' do

    before do
      stub_definitions
      stub_job_creation
    end

    it 'clusters' do
      body = {
        'node_ids' => ['3b6eb27f-3e83-4751-9d45-85a989ae2b25'],
        'sds_name' => 'ceph 10.2.5',
        'sds_version' => '10.2.5',
        'sds_type' => 'ceph'
      }
      post '/ImportCluster', body.to_json, http_env
      expect(last_response.status).to eq 202
    end

  end

  context 'list' do

    before do
      stub_nodes
      stub_clusters(false)
    end

    it 'nodes without monitoring' do
      stub_monitoring_config(404, "monitoring_config_error.json")
      get "/GetNodeList", {}, http_env
      puts last_response.errors
      expect(last_response.status).to eq 200
    end

    it 'nodes with monitoring' do
      stub_monitoring_config
      stub_node_monitoring
      get "/GetNodeList", {}, http_env
      expect(last_response.status).to eq 200
    end


  end

end

