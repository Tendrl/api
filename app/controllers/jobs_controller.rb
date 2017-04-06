class JobsController < AuthenticatedUsersController

  get '/jobs' do
    begin
      jobs = Tendrl::Job.all
    rescue Etcd::KeyNotFound
      jobs = []
    end
    { jobs: JobPresenter.list(jobs) }.to_json
  end

  get '/jobs/:job_id' do
    JobPresenter.single(Tendrl::Job.find(params[:job_id])).to_json
  end

  get '/jobs/:job_id/messages' do
    job = Tendrl::Job.find(params[:job_id])
    parent_job_messages = Tendrl::Job.messages(params[:job_id])
    child_job_messages = Tendrl::Job.children_messages(params[:job_id])
    jobs = (parent_job_messages + child_job_messages.flatten).sort do |a, b|
      Time.parse(a['timestamp']) <=> Time.parse(b['timestamp'])
    end
    jobs.to_json
  end

  get '/jobs/:job_id/status' do
    Tendrl::Job.status(params[:job_id]).to_json
  end

end
