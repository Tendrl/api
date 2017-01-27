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

end

