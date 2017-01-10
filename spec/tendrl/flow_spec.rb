require 'spec_helper'

RSpec.describe Tendrl::Flow do

  before do
    definitions = JSON.parse(File.read(
      'spec/fixtures/definitions/tendrl_definitions_node_agent.json'
    ))['node']['value']
    Tendrl.node_definitions = YAML.load(definitions)
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
