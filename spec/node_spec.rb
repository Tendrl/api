require 'spec_helper'

describe Node do

  before do
    stub_definitions
  end

  it 'Flows' do
    get "/Flows", { "CONTENT_TYPE" => "application/json" }
    expect(last_response.status).to eq 200
  end

  context 'list' do

    before do
      stub_nodes
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

