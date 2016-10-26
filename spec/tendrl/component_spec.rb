require 'spec_helper'

RSpec.describe Tendrl::Component do

  context "initialization" do

    it 'sets the correct object type' do
      expect(Tendrl::Component.new('gluster-3.8.3', 'volume').object_type).to eq('volume')
    end

    it 'raises an exception for undefined object type' do
      expect{ Tendrl::Component.new('gluster-3.8.3', 'blah') }.to raise_error Tendrl::InvalidObjectError
    end

    it 'sets defined sds version' do
      expect(Tendrl::Component.new('gluster-3.8.3', 'volume').sds_version).to eq('gluster-3.8.3')
    end

    it 'sets the defined attributes' do
      expect(Tendrl::Component.new('gluster-3.8.3', 'volume').attributes).to include('volname', 'brickdetails')
    end

    it 'sets the defined performable actions' do
      expect(Tendrl::Component.new('gluster-3.8.3', 'volume').actions.keys).to include('create')
    end

  end

end
