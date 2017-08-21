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
    stub_access_token
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

  context 'import' do

    before do
      stub_definitions
      stub_unmanaged_cluster
      stub_job_creation
    end

    it 'unmanaged' do
      body = {
        enable_volume_profiling: true
      }
      post '/clusters/6b4b84e0-17b3-4543-af9f-e42000c52bfc/import',
        body.to_json,
        http_env
      expect(last_response.status).to eq 202
    end

  end

  context 'profiling' do

    before do
      stub_cluster
      stub_cluster_profiling
    end

    it 'enable' do
      body = {
        enable_volume_profiling: true
      }
      put '/clusters/6b4b84e0-17b3-4543-af9f-e42000c52bfc/profiling',
        body.to_json,
        http_env
      expect(last_response.status).to eq 200
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

    context 'pools' do

      before do
        stub_cluster_definitions('ceph')
        stub_pools
        stub_node_ids
      end

      it 'list' do
        get '/clusters/6b4b84e0-17b3-4543-af9f-e42000c52bfc/pools', {}, http_env
        expect(last_response.status).to eq 200
      end

      it 'create' do
        body = { 
          "Pool.poolname" => "pool_009",
          "Pool.pg_num" => 128,
          "Pool.min_size" => 1
        }

        post '/clusters/6b4b84e0-17b3-4543-af9f-e42000c52bfc/CephCreatePool',
          body.to_json,
          http_env
        expect(last_response.status).to eq 202
      end

      it 'update' do
        body = { 
          "Pool.pool_id" => "0",
          "Pool.poolname" => "pool_009",
          "Pool.pg_num" => 128,
          "Pool.min_size" => 1
        }

        put '/clusters/6b4b84e0-17b3-4543-af9f-e42000c52bfc/CephUpdatePool',
          body.to_json,
          http_env
        expect(last_response.status).to eq 202
      end

      it 'delete' do
        body = {
          "Pool.poolname" => "pool_009",
          "Pool.pool_id" => "f2e68a00-71c9 -4efc-a28b-7204acf9ecff"
        }

        delete '/clusters/6b4b84e0-17b3-4543-af9f-e42000c52bfc/CephDeletePool',
          body.to_json,
          http_env
        expect(last_response.status).to eq 202
      end

      context 'rbds' do

        it 'create' do
          body = { 
            "Rbd.pool_id" => "0",
            "Rbd.name" => 'RBD_009',
            "Rbd.size" => 1024
          }

          post '/clusters/6b4b84e0-17b3-4543-af9f-e42000c52bfc/CephCreateRbd',
            body.to_json,
            http_env
          expect(last_response.status).to eq 202
        end

        it 'resize' do
          body = { 
            "Rbd.pool_id" => "0",
            "Rbd.name" => 'RBD_009',
            "Rbd.size" => 2048
          }

          put '/clusters/6b4b84e0-17b3-4543-af9f-e42000c52bfc/CephResizeRbd',
            body.to_json,
            http_env
          expect(last_response.status).to eq 202
        end

        it 'delete' do
          body = {
            "Rbd.pool_id" => "0",
            "Rbd.name" => 'RBD_009',
          }

          delete '/clusters/6b4b84e0-17b3-4543-af9f-e42000c52bfc/CephDeletePool',
            body.to_json,
            http_env
          expect(last_response.status).to eq 202
        end

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

      it 'create' do
        body = { 
          "Volume.volname" => "Volume_009",
          "Volume.bricks" => [
            "dhcp-1.lab.tendrl.example:/root/bricks/vol9_b1"
          ] 
        }
        post '/clusters/6b4b84e0-17b3-4543-af9f-e42000c52bfc/GlusterCreateVolume',
          body.to_json,
          http_env
        expect(last_response.status).to eq 202
      end

      it 'delete' do
        body = {
          "Volume.volname" => "Volume_009",
          "Volume.vol_id" => "f2e68a00-71c9-4efc-a28b-7204acf9ecff"
        } 
        delete '/clusters/6b4b84e0-17b3-4543-af9f-e42000c52bfc/GlusterDeleteVolume',
          body.to_json,
          http_env
        expect(last_response.status).to eq 202
      end
    end

    context 'bricks' do

      before do
        stub_cluster_definitions('gluster')
        stub_node_ids
      end

      it 'create' do
        body = {
          "Cluster.node_configuration" => {
            "3e062731-81e4-4b5d-99d0-69f4a7133da0" => {
              "vdb" => {
                "brick_name" => "brick_1",
              },
            },
            "e267a3e6-ad7e-482e-a9f9-43a7e8e2c2f5" => {
              "vdb" => {
                "brick_name" => "brick_2",
              },
            },
          },
        }
        post '/clusters/6b4b84e0-17b3-4543-af9f-e42000c52bfc/GlusterCreateBrick',
          body.to_json,
          http_env
        expect(last_response.status).to eq 202
      end

    end

  end
end

