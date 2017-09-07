require 'spec_helper'
require './app/controllers/users_controller'

RSpec.describe UsersController do

  context "admin user" do

    let(:http_env){
      {
        'HTTP_AUTHORIZATION' => 'Bearer d03ebb195dbe6385a7caeda699f9930ff2e49f29c381ed82dc95aa642a7660b8',
        'CONTENT_TYPE' => 'application/json'
      }
    }

    before do
      stub_users
      stub_user('dwarner')
      stub_access_token('dwarner')
    end

    context 'create' do

      let(:body){
        {
          email: 'thardy@tendrl.org',
          username: 'thardy',
          name: 'Tom Hardy',
          password: 'temp1234',
          password_confirmation: 'temp1234',
          role: 'admin',
          email_notifications: true
        }
      }

      before do
        stub_user_create(body[:username])
        stub_create_user_attributes(body)
        stub_user(body[:username])
        stub_email_notifications_index(body[:username], body[:email])
      end

      it 'invalid attributes' do
        post "/users", { username: body[:username] }.to_json, http_env
        expect(last_response.status).to eq(422)
      end

      it 'valid attributes' do
        post "/users", body.to_json, http_env
        expect(last_response.status).to eq(201)
      end

    end

    context 'update' do

    end

    context 'delete' do

      it 'other non admin user succssfully' do
        stub_user('quentin')
        stub_delete_user('quentin')
        delete "/users/quentin", {}, http_env
        expect(last_response.status).to eq(200)
      end

      it 'self unsuccessfully' do
        delete "/users/dwarner", {}, http_env
        expect(last_response.status).to eq(403)
      end

    end
  end

  context "normal user" do

    let(:http_env){
      {
        'HTTP_AUTHORIZATION' => 'Bearer d03ebb195dbe6385a7caeda699f9930ff2e49f29c381ed82dc95aa642a7660b8',
        'CONTENT_TYPE' => 'application/json'
      }
    }

    context 'create' do

      before do
        stub_user('quentin')
        stub_access_token('quentin')
      end


      it 'new user is forbidden' do
        post "/users", {}.to_json, http_env
        expect(last_response.status).to eq(403)
      end

    end

    context 'update' do

      before do
        stub_users
        stub_user('quentin')
        stub_access_token('quentin')
        stub_failed_create_existing_user('quentin')
      end

      it 'existing user is forbidden' do
        put "/users/thardy", { name: 'Hardy' }.to_json, http_env
        expect(last_response.status).to eq(403)
      end

      it 'self' do
        stub_email_notifications_index('quentin', 'quentin@tendrl.org')
        body = { name: 'Quentin D' }
        stub_update_user_attributes('quentin', body)
        put "/users/quentin", body.to_json, http_env
        expect(last_response.status).to eq(200)
      end

    end
  end
end
