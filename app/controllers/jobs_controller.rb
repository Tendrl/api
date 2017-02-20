class JobsController < AuthenticatedUsersController

  get '/jobs' do
    jobs = []
    etcd.get('/queue', recursive: true).children.each do |job|
      job = JSON.parse(job.value)
      jobs << JobPresenter.single(job) if job['created_from'] == 'API'
    end
    jobs.to_json
  end

  get '/jobs/:job_id' do
    jobs = []
    job = JSON.parse(etcd.get("/queue/#{params[:job_id]}").value)
    JobPresenter.single(job).to_json
  end

  get '/jobs/:job_id/logs' do
    params[:type] ||= 'all'
    job = JSON.parse(etcd.get("/queue/#{params[:job_id]}").value)
    request_id = job['request_id']
    logs = etcd.get("/#{request_id}/#{params[:type]}").value
    { logs: logs, type: params[:type] }.to_json
  end

end
