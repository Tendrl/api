require 'spec_helper'

describe Cluster do

  context 'list' do

    before do
      stub_clusters
    end

    it 'cluster without monitoring' do
      stub_monitoring_config(404, "monitoring_config_error.json")
      get "/GetClusterList", { "CONTENT_TYPE" => "application/json" }
      expect(last_response.status).to eq 200
    end

    it 'cluster with monitoring stats' do
      stub_monitoring_config
      stub_cluster_monitoring
      get "/GetClusterList", { "CONTENT_TYPE" => "application/json" }
      expect(last_response.status).to eq 200
    end

  end

  context 'pools' do

    before do
      stub_cluster_context
      stub_pools
    end

    it 'list' do
      get '/6b4b84e0-17b3-4543-af9f-e42000c52bfc/GetPoolList',
        { 'CONTEXT_TYPE' => 'application/json' }
      expect(last_response.status).to eq 200
    end

  end

  # context 'volumes' do
  #
  #   it 'list' do
  #     get '/GetPoolsList', { 'CONTEXT_TYPE' => 'application/json' }
  #     expect(last_response).to eq 200
  #   end
  #
  # end

end

