class JobsController < AuthenticatedUsersController

  get '/jobs' do
    JobPresenter.list(Tendrl::Job.all).to_json
  end

  get '/jobs/:job_id' do
    JobPresenter.single(Tendrl::Job.find(params[:job_id])).to_json
  end

  get '/jobs/:job_id/messages' do
    Tendrl::Job.messages(params[:job_id]).to_json
  end

  get '/jobs/:job_id/status' do
    Tendrl::Job.status(params[:job_id]).to_json
  end

end
