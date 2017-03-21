class JobsController < AuthenticatedUsersController

  get '/jobs' do
    { jobs: JobPresenter.list(Tendrl::Job.all) }.to_json
  end

  get '/jobs/:job_id' do
    JobPresenter.single(Tendrl::Job.find(params[:job_id])).to_json
  end

  get '/jobs/:job_id/messages' do
    job = Tendrl::Job.find(params[:job_id])
    parent_job_messages = Tendrl::Job.messages(params[:job_id])
    child_job_messages = Tendrl::Job.children_messages(params[:job_id])
    (parent_job_messages + child_job_messages.flatten).to_json
  end

  get '/jobs/:job_id/status' do
    Tendrl::Job.status(params[:job_id]).to_json
  end

end
