require 'spec_helper'

describe Base do

  context 'jobs' do

    it 'list' do
      stub_jobs
      get '/jobs', { "CONTENT_TYPE" => "application/json" }
      expect(last_response.status).to eq 200
    end

    it 'details' do
      stub_job
      get '/jobs/165bd201-2bee-44e9-a706-321290db798c',
        { "CONTENT_TYPE" => "application/json" }
      expect(last_response.status).to eq 200
    end

  end

end
