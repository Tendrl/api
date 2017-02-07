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

  context 'actions' do

    before do
      stub_cluster_context
      stub_job_creation
    end

    context 'pools' do

      before do
        stub_cluster_definitions('ceph')
        stub_pools
        stub_node_ids
      end

      it 'list' do
        get '/6b4b84e0-17b3-4543-af9f-e42000c52bfc/GetPoolList'
        expect(last_response.status).to eq 200
      end

      it 'create' do
        body = { 
          "Pool.poolname" => "pool_009",
          "Pool.pg_num" => 128,
          "Pool.min_size" => 1
        }

        post '/6b4b84e0-17b3-4543-af9f-e42000c52bfc/CephCreatePool',
          body.to_json,
          { 'CONTENT_TYPE' => 'application/json' }
        expect(last_response.status).to eq 202
      end

      it 'update' do
        body = { 
          "Pool.pool_id" => "0",
          "Pool.poolname" => "pool_009",
          "Pool.pg_num" => 128,
          "Pool.min_size" => 1
        }

        put '/6b4b84e0-17b3-4543-af9f-e42000c52bfc/CephUpdatePool',
          body.to_json
        expect(last_response.status).to eq 202
      end

      it 'delete' do
        body = {
          "Pool.poolname" => "pool_009",
          "Pool.pool_id" => "f2e68a00-71c9 -4efc-a28b-7204acf9ecff"
        }

        delete '/6b4b84e0-17b3-4543-af9f-e42000c52bfc/CephDeletePool',
          body.to_json
        expect(last_response.status).to eq 202
      end

      context 'rbds' do

        it 'create' do
          body = { 
            "Rbd.pool_id" => "0",
            "Rbd.name" => 'RBD_009',
            "Rbd.size" => 1024
          }

          post '/6b4b84e0-17b3-4543-af9f-e42000c52bfc/CephCreateRbd',
            body.to_json,
            { 'CONTENT_TYPE' => 'application/json' }
          expect(last_response.status).to eq 202
        end

        it 'resize' do
          body = { 
            "Rbd.pool_id" => "0",
            "Rbd.name" => 'RBD_009',
            "Rbd.size" => 2048
          }

          put '/6b4b84e0-17b3-4543-af9f-e42000c52bfc/CephResizeRbd',
            body.to_json
          expect(last_response.status).to eq 202
        end

        it 'delete' do
          body = {
            "Rbd.pool_id" => "0",
            "Rbd.name" => 'RBD_009',
          }

          delete '/6b4b84e0-17b3-4543-af9f-e42000c52bfc/CephDeletePool',
            body.to_json
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
        get '/6b4b84e0-17b3-4543-af9f-e42000c52bfc/GetVolumesList'
        expect(last_response.status).to eq 200
      end

      it 'create' do
        body = { 
          "Volume.volname" => "Volume_009",
          "Volume.bricks" => [
            "dhcp-1.lab.tendrl.example:/root/bricks/vol9_b1"
          ] 
        }
        post '6b4b84e0-17b3-4543-af9f-e42000c52bfc/GlusterCreateVolume',
          body.to_json,
          { 'CONTEXT_TYPE' => 'application/json' }
        expect(last_response.status).to eq 202
      end

      it 'delete' do
        body = {
          "Volume.volname" => "Volume_009",
          "Volume.vol_id" => "f2e68a00-71c9-4efc-a28b-7204acf9ecff"
        } 
        delete '/6b4b84e0-17b3-4543-af9f-e42000c52bfc/GlusterDeleteVolume',
          body.to_json
        expect(last_response.status).to eq 202
      end

    end
  end

end

