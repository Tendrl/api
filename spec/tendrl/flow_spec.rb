require 'spec_helper'

RSpec.describe Tendrl::Flow do

  context 'node' do

    before do
      Tendrl.node_definitions = YAML.load_file(
        'spec/fixtures/definitions/master.yaml'
      )
    end

    it 'ImportCluster' do
      flow = Tendrl::Flow.new(
        'namespace.tendrl',
        'ImportCluster'
      )
      expect(flow.flow_name).to eq('ImportCluster')
      expect(flow.tags({ 'DetectedCluster.detected_cluster_id' => '12345'})).to eq(['detected_cluster/12345'])
    end

    it 'CreateCluster' do
      flow = Tendrl::Flow.new(
        'namespace.tendrl',
        'CreateCluster'
      )
      expect(flow.flow_name).to eq('CreateCluster')
      expect(flow.tags({ 'TendrlContext.sds_name' => 'ceph'})).to eq(['provisioner/ceph'])
    end


  end

  context 'cluster' do

    context 'gluster' do

      before do
        Tendrl.cluster_definitions = YAML.load_file(
          'spec/fixtures/definitions/gluster.yaml'
        )
      end

      it 'CreateVolume' do
        flow = Tendrl::Flow.new(
          'namespace.gluster',
          'CreateVolume'
        )
        expect(flow.flow_name).to eq('CreateVolume')
        expect(flow.tags({ 'TendrlContext.integration_id' => '12345'})).to eq(['tendrl/integration/12345'])
      end

    end

    context 'ceph' do

      before do
        Tendrl.cluster_definitions = YAML.load_file(
          'spec/fixtures/definitions/ceph.yaml'
        )
      end

      it 'CreatePool' do
        flow = Tendrl::Flow.new(
          'namespace.ceph',
          'CreatePool'
        )
        expect(flow.flow_name).to eq('CreatePool')
        expect(flow.tags({ 'TendrlContext.integration_id' => '12345'})).to eq(['tendrl/integration/12345'])
      end

    end

  end

  context 'node agent' do

    before do
      Tendrl.node_definitions = YAML.load_file(
        'spec/fixtures/definitions/master.yaml'
      )
    end

    it 'GenerateJournalMapping' do
      flow = Tendrl::Flow.new(
        'namespace.node_agent',
        'GenerateJournalMapping'
      )
      expect(flow.flow_name).to eq('GenerateJournalMapping')
    end


  end


end
