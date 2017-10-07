require 'spec_helper'
require './app/controllers/authenticated_users_controller'

RSpec.describe AuthenticatedUsersController do

  let(:http_env){
    {
      'HTTP_AUTHORIZATION' => 'Bearer d03ebb195dbe6385a7caeda699f9930ff2e49f29c381ed82dc95aa642a7660b8',
      'CONTENT_TYPE' => 'application/json'
    }
  }

  before do
    stub_user('dwarner')
    stub_access_token('dwarner')
  end

  context 'users' do

    it 'current' do
      get "/current_user",{}, http_env
      expect(last_response.status).to eq 200
    end
  end
end
