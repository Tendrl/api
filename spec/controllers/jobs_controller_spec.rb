require 'spec_helper'
require './app/controllers/jobs_controller'

describe JobsController do

  let(:http_env){
    {
      'HTTP_AUTHORIZATION' => 'Bearer d03ebb195dbe6385a7caeda699f9930ff2e49f29c381ed82dc95aa642a7660b8',
      'CONTENT_TYPE' => 'application/json'
    }
  }

  before do
    stub_user('dwarner')
    stub_access_token
  end

  context 'jobs' do

    it 'list' do
      stub_jobs
      get '/jobs', {}, http_env
      expect(last_response.status).to eq 200
    end

    it 'details' do
      stub_job
      get '/jobs/165bd201-2bee-44e9-a706-321290db798c', {}, http_env
      expect(last_response.status).to eq 200
    end

  end

end
