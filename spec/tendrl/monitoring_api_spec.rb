require 'spec_helper'

RSpec.describe Tendrl::MonitoringApi do

  let :monitoring do
    config_json = JSON.parse(
      File.read(
        'spec/fixtures/monitoring_config.json'
      )
    )
    config = YAML.load(config_json['node']['value'])
    Tendrl::MonitoringApi.new(config)
  end

  context 'nodes' do

    it 'stats' do
      stub_node_monitoring
      monitoring.node_stats
    end

  end

  context 'cluster' do

    it 'stats' do
      stub_cluster_monitoring
      monitoring.cluster_stats
    end

  end

end
