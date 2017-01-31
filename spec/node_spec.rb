require 'spec_helper'

describe Node do

  before do
    stub_definitions
  end

  it 'Flows' do
    get "/Flows", { "CONTENT_TYPE" => "application/json" }
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
      post '/ImportCluster', body.to_json, { 'CONTENT_TYPE' => 'application/json' }
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
      get "/GetNodeList", { "CONTENT_TYPE" => "application/json" }
      expect(last_response.status).to eq 200
    end

    it 'nodes with monitoring' do
      stub_monitoring_config
      stub_node_monitoring
      get "/GetNodeList", { "CONTENT_TYPE" => "application/json" }
      expect(last_response.status).to eq 200
    end


  end

end

