class JobsController < AuthenticatedUsersController

  get '/jobs' do
    begin
      jobs = Tendrl::Job.all
    rescue Etcd::KeyNotFound
      jobs = []
    end
    { jobs: JobPresenter.list(jobs) }.to_json
  end

  before '/jobs/:job_id/?*?' do
    begin
      Tendrl.etcd.get "/queue/#{params[:job_id]}"
    rescue Etcd::KeyNotFound => e
      e = Tendrl::HttpResponseErrorHandler.new(
        e, cause: '/jobs/id', object_id: params[:job_id]
      )
      halt e.status, e.body.to_json
    end
  end

  get '/jobs/:job_id' do
    JobPresenter.single(Tendrl::Job.find(params[:job_id])).to_json
  end

  get '/jobs/:job_id/messages' do
    parent_job_messages = Tendrl::Job.messages(params[:job_id])
    child_job_messages = Tendrl::Job.children_messages(params[:job_id])
    jobs = (parent_job_messages + child_job_messages.flatten).sort do |a, b|
      Time.parse(a['timestamp']) <=> Time.parse(b['timestamp'])
    end
    jobs.to_json
  end

  get '/jobs/:job_id/output' do
    Tendrl::Job.output(params[:job_id]).to_json
  end

  get '/jobs/:job_id/status' do
    Tendrl::Job.status(params[:job_id]).to_json
  end
end
