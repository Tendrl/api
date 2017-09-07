require 'spec_helper'

RSpec.describe Tendrl::User do

  before do
    Tendrl.etcd = Etcd::Client.new
  end
  
  it 'create' do
    stub_email_notifications_index('dwarner', 'dwarner@tendrl.org')
    stub_user('dwarner')
    stub_user_create('dwarner')
    attributes = {
      email: 'dwarner@tendrl.org',
      name: 'David Warner',
      username: 'dwarner',
      password: 'temp1234'
    }
    stub_create_user_attributes(attributes)
    user = Tendrl::User.save(attributes)
    expect(user.username).to eq('dwarner')
  end

  context 'authentication' do

    before do
      stub_user('dwarner')
      stub_access_token('dwarner')
    end

    it 'with valid username and password' do
      user = Tendrl::User.authenticate('dwarner', 'temp1234')
      expect(user).to be_present
      expect(user.username).to eq('dwarner')
    end

    it 'with invalid username or password' do
      user = Tendrl::User.authenticate('dwarner', 'temp123')
      expect(user).to be_nil
    end

    it 'with valid access_token' do
      user = Tendrl::User.authenticate_access_token('d03ebb195dbe6385a7caeda699f9930ff2e49f29c381ed82dc95aa642a7660b8')
      expect(user).to be_present
      expect(user.username).to eq('dwarner')
    end

    it 'with invalid username or access_token' do
      user = Tendrl::User.authenticate('dwarner', 'blah')
      expect(user).to be_nil
    end

  end

  
end
