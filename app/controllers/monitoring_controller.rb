class MonitoringController < AuthenticatedUsersController

  before '/monitoring/*'do
    halt 404, { 
      errors: { 
        message: 'Monitoring API not configured' 
      } 
    }.to_json if monitoring.nil?
  end

  get '/monitoring/nodes' do
    response = @monitoring.nodes(params[:node_ids].to_s.split(',').compact)
    { stats: response }.to_json
  end

  get '/monitoring/cluster/:cluster_id' do
    response = @monitoring.cluster(params[:cluster_id])
    { stats: response }.to_json
  end

  get '/monitoring/system/:sds_name' do
    response = @monitoring.system(params[:sds_name])
    { stats: response }.to_json
  end

  get '/monitoring/system/:sds_name/utilization' do
    response = @monitoring.system_utilization(params[:sds_name])
    { stats: response }.to_json
  end

  get '/monitoring/cluster/:cluster_id/utilization' do
    response = @monitoring.cluster_utilization(params[:cluster_id])
    { stats: response }.to_json
  end

end
