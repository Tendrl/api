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
    stub_users
    stub_user('dwarner')
    stub_access_token
  end

  context 'create' do

    let(:body){
      {
        email: 'thardy@tendrl.org',
        username: 'thardy',
        name: 'Tom Hardy',
        password: 'temp1234',
        password_confirmation: 'temp1234',
        role: 'normal',
        email_notifications: true
      }
    }

    before do
      stub_user_create(body[:username])
      stub_create_user_attributes(body)
      stub_user('thardy')
    end

    it 'invalid attributes' do
      post "/users", { username: body[:username] }.to_json, http_env
      expect(last_response.status).to eq(400)
    end

    it 'valid attributes' do
      post "/users", body.to_json, http_env
      expect(last_response.status).to eq(201)
    end

  end

  it 'update'

  it 'delete'

  it 'lists'

  it 'single'

  it 'current'

end
