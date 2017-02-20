require 'spec_helper'

RSpec.describe Tendrl::User do

  before do
    Tendrl.etcd = Etcd::Client.new
  end
  
  it 'create' do
    stub_user('thardy')
    stub_create_user('thardy')
    attributes = {
      email: 'thardy@tendrl.org',
      name: 'Tom Hardy',
      username: 'thardy',
      password: 'temp1234'
    }
    stub_create_user_attributes(attributes)
    expect(Tendrl::User.save(attributes)).to eq(true)
  end

  context 'authentication' do

    it 'with valid username and password' do
      stub_user('dwarner')
      user = Tendrl::User.authenticate('dwarner', 'temp1234')
      expect(user).to be_present
      expect(user.username).to eq('dwarner')
    end

    it 'with invalid username or password' do
      stub_user('dwarner')
      user = Tendrl::User.authenticate('dwarner', 'temp123')
      expect(user).to be_nil
    end

    it 'with valid username and access_token' do
      stub_user('dwarner')
      user = Tendrl::User.authenticate_access_token('dwarner', 'd03ebb195dbe6385a7caeda699f9930ff2e49f29c381ed82dc95aa642a7660b8')
      expect(user).to be_present
      expect(user.username).to eq('dwarner')
    end

    it 'with invalid username or access_token' do
      stub_user('dwarner')
      user = Tendrl::User.authenticate('dwarner', 'blah')
      expect(user).to be_nil
    end

  end

  
end
