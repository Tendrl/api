require 'spec_helper'
require './app/controllers/users_controller'

RSpec.describe UsersController do

  let(:http_env){
    {
      'HTTP_USER_AGENT' => 'dwarner',
      'HTTP_AUTHORIZATION' => 'Bearer d03ebb195dbe6385a7caeda699f9930ff2e49f29c381ed82dc95aa642a7660b8',
      'CONTENT_TYPE' => 'application/json'
    }
  }

  before do
    stub_user('dwarner')
  end

  it 'create' do
  end

  it 'update' do
  end

  it 'delete' do
  end

  it 'lists' do
  end

  it 'single' do

  end


end
