require 'spec_helper'

describe 'API' do

  before do
    etcd = instance_double(Etcd::Client)
    allow(etcd).to receive(:get).and_return({ sds_version: 'gluster-3.8.3' })
    allow(etcd).to receive(:set).and_return({ })
    App.settings.etcd = etcd
    @cluster_id = 'd74371ad-c292-4ccd-949c-d48de9472afd'
  end

  context 'Volume Definitions' do

    it 'actions' do
      get "/cluster/#{@cluster_id}/volume/actions",
        { "CONTENT_TYPE" => "application/json" }
        expect(last_response.status).to eq 200
    end

    it 'attributes' do
      get "/cluster/#{@cluster_id}/volume/attributes",
        { "CONTENT_TYPE" => "application/json" }
        expect(last_response.status).to eq 200
    end

  end

  context 'Volume actions' do

    it 'create' do
      body = { volname: 'test-volume',
               replica_count: 2,
               stripe_count: 2,
               transport: 'tcp',
               brickdetails: ['server1:/exp1', 'server2:/exp2',
                       'server3:/exp3', 'server4:/exp'],
               force: false }.to_json
      post "/cluster/#{@cluster_id}/volume/create", body,
        { "CONTENT_TYPE" => "application/json" }
      expect(last_response.status).to eq 202
      response_body = JSON.parse(last_response.body)
      expect(response_body['job_id']).to be_present
      expect(response_body['status']).to eq('processing')
    end

  end

end

