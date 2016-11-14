require 'spec_helper'

RSpec.describe Tendrl::Flow do

  before do
    Tendrl.node_definitions = YAML.load_file(
      'spec/fixtures/definitions/tendrl_definitions_node_agent.yaml'
    )
  end

  context 'node' do

    it 'initialize' do
      flow = Tendrl::Flow.new(
        'namespace.tendrl.node_agent.gluster_integration',
        'ImportCluster'
      )
      expect(flow.objects.length).to eq(4)
      expect(flow.type).to eq('create')
      expect(flow.method).to eq('POST')
    end

  end

end
