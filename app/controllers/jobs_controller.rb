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
      @job = Tendrl::Job.find(params[:job_id])
    rescue Etcd::KeyNotFound => e
      e = Tendrl::HttpResponseErrorHandler.new(
        e, cause: '/jobs/id', object_id: params[:job_id]
      )
      halt e.status, e.body.to_json
    end
  end

  get '/jobs/:job_id' do
    JobPresenter.single(@job).to_json
  end

  get '/jobs/:job_id/messages' do
    parent_job_messages = Tendrl::Job.messages(params[:job_id])
    child_job_ids = JSON.parse @job.fetch('children', '[]')
    child_job_messages = child_job_ids.map do |child_id|
      Tendrl::Job.messages child_id
    end
    jobs = (parent_job_messages + child_job_messages.flatten).sort do |a, b|
      Time.parse(a['timestamp']) <=> Time.parse(b['timestamp'])
    end
    jobs.to_json
  end

  get '/jobs/:job_id/output' do
    @job['output'].to_json
  end

  get '/jobs/:job_id/status' do
    { status: @job['status'] }.to_json
  end
end
