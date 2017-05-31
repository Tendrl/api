class MonitoringController < AuthenticatedUsersController

  before '/monitoring/*'do
    halt 404, { 
      errors: { 
        message: 'Monitoring API not configured' 
      } 
    }.to_json if monitoring.nil?
  end

  get '/monitoring/nodes' do
    response = @monitoring.nodes(params[:node_ids])
    { stats: response }.to_json
  end

  get '/monitoring/node/:node_id/memory' do
    response = @monitoring.node_memory_percent_used(params[:node_id])
    { stats: response }.to_json
  end

  get '/monitoring/node/:node_id/swap' do
    response = @monitoring.node_swap_percent_used(params[:node_id])
    { stats: response }.to_json
  end

  get '/monitoring/node/:node_id/throughput' do
    response = @monitoring.node_throughput(params[:node_id], params[:type])
    { stats: response }.to_json
  end

  get '/monitoring/node/:node_id/iops' do
    response = @monitoring.node_iops(params[:node_id])
    { stats: response }.to_json
  end

  get '/monitoring/node/:node_id/cpu' do
    response = @monitoring.node_cpu(params[:node_id])
    { stats: response }.to_json
  end

  get '/monitoring/node/:node_id/storage' do
    response = @monitoring.node_storage(params[:node_id])
    { stats: response }.to_json
  end

  get '/monitoring/cluster/:cluster_id' do
    response = @monitoring.cluster(params[:cluster_id])
    { stats: response }.to_json
  end

  get '/monitoring/cluster/:cluster_id/utilization' do
    response = @monitoring.cluster_utilization(params[:cluster_id])
    { stats: response }.to_json
  end

  get '/monitoring/cluster/:cluster_id/throughput' do
    response = @monitoring.cluster_throughput(params[:cluster_id],
                                              params[:type])
    { stats: response }.to_json
  end

  get '/monitoring/cluster/:cluster_id/iops' do
    response = @monitoring.cluster_iops(params[:cluster_id])
    { stats: response }.to_json
  end

  get '/monitoring/cluster/:cluster_id/latency' do
    response = @monitoring.cluster_latency(params[:cluster_id])
    { stats: response }.to_json
  end

  get '/monitoring/clusters/iops' do
    response = @monitoring.clusters_iops(params[:cluster_ids])
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

  get '/monitoring/system/:sds_name/throughput' do
    response = @monitoring.system_throughput(params[:sds_name], params[:type])
    { stats: response }.to_json
  end
  
end
