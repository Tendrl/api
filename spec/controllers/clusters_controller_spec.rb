require 'spec_helper'
require './app/controllers/clusters_controller'

describe ClustersController do

  let(:http_env){
    {
      'HTTP_AUTHORIZATION' => 'Bearer d03ebb195dbe6385a7caeda699f9930ff2e49f29c381ed82dc95aa642a7660b8',
      'CONTENT_TYPE' => 'application/json'
    }
  }

  before do
    stub_user('dwarner')
    stub_access_token('dwarner')
  end

  context 'list' do

    before do
      stub_clusters
    end

    it 'clusters' do
      get "/clusters", {}, http_env
      expect(last_response.status).to eq 200
    end

  end

  context 'show' do
    before do
      stub_cluster
    end

    specify 'cluster details' do
      get '/clusters/6b4b84e0-17b3-4543-af9f-e42000c52bfc', nil, http_env
      expect(last_response.status).to eq 200
      body = JSON.parse last_response.body
      expect(body['short_name']).to eq('cluster-short-name')
    end
  end

  context 'import' do
    before do
      stub_definitions
    end

    it 'unmanaged' do
      stub_unmanaged_cluster
      stub_job_creation
      body = {
        'Cluster.volume_profiling_flag' => "enable"
      }
      post '/clusters/6b4b84e0-17b3-4543-af9f-e42000c52bfc/import',
        body.to_json,
        http_env
      expect(last_response.status).to eq 202
    end

    specify 'unknown cluster' do
      stub_unknown_cluster
      post '/clusters/unknown/import', '{}', http_env
      expect(last_response.status).to eq 404
    end
  end

  context 'expand' do
    before do
      stub_definitions
      stub_unmanaged_cluster
      stub_job_creation
    end

    specify 'cluster with detected peers' do
      post '/clusters/6b4b84e0-17b3-4543-af9f-e42000c52bfc/expand',
           nil, http_env
      expect(last_response.status).to eq 202
    end
  end

  context 'unmanage' do

    before do
      stub_definitions
      stub_managed_cluster
      stub_job_creation
    end

    it 'managed' do
      post '/clusters/6b4b84e0-17b3-4543-af9f-e42000c52bfc/unmanage',
      '{}', http_env
      expect(last_response.status).to eq 202

      post '/clusters/6b4b84e0-17b3-4543-af9f-e42000c52bfc/unmanage',
      nil, http_env
      expect(last_response.status).to eq 202
    end

  end

  context 'profiling' do

    before do
      stub_cluster
      stub_cluster_profiling
      stub_cluster_definitions
      stub_job_creation
    end

    it 'enable' do
      body = {
        'Cluster.volume_profiling_flag' => 'enable'
      }
      post '/clusters/6b4b84e0-17b3-4543-af9f-e42000c52bfc/profiling',
        body.to_json,
        http_env
      expect(last_response.status).to eq 202
    end

    specify 'start_profiling' do
      post '/clusters/6b4b84e0-17b3-4543-af9f-e42000c52bfc/volumes/3199b12f-0626-44ea-9315-03614a595e90/start_profiling',
           nil, http_env
      expect(last_response.status).to eq 202
    end

    specify 'stop_profiling' do
      post '/clusters/6b4b84e0-17b3-4543-af9f-e42000c52bfc/volumes/3199b12f-0626-44ea-9315-03614a595e90/stop_profiling',
           nil, http_env
      expect(last_response.status).to eq 202
    end
  end

  context 'actions' do

    before do
      stub_cluster_context
      stub_job_creation
    end

    context 'unknown object' do

      before do
        stub_cluster_definitions('ceph')
        stub_node_ids
      end

      it 'list' do
        get '/clusters/6b4b84e0-17b3-4543-af9f-e42000c52bfc/GetNodeList',
          {},
          http_env
        expect(last_response.status).to eq(404)
      end

    end

    context 'volumes' do

      before do
        stub_cluster_definitions('gluster')
        stub_volumes
        stub_node_ids
      end

      it 'list' do
        get '/clusters/6b4b84e0-17b3-4543-af9f-e42000c52bfc/volumes', {},
          http_env
        expect(last_response.status).to eq 200
      end

    end

    context 'bricks' do

    end

  end
end

