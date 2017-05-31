require 'spec_helper'

RSpec.describe Tendrl::MonitoringApi do

  let :monitoring do
    config = {
      "log_level"=>"DEBUG",
      "api_server_port"=>"5000",
      "api_server_addr"=>"127.0.0.1"
    }   
    Tendrl::MonitoringApi.new(config)
  end

  context 'nodes' do

    it 'stats' do
      stub_node_monitoring
      monitoring.nodes
    end

  end

end
