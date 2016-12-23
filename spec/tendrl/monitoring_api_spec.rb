require 'spec_helper'

RSpec.describe Tendrl::MonitoringApi do

  let :monitoring do
    Tendrl::MonitoringApi.new({ url: 'http://127.0.0.1:9000' })
  end

  before do
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
