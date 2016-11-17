require './base'

class Cluster < Base

  get '/ping' do
    'pong'
  end

  get '/cluster/:cluster_id/:object_type/attributes' do
    cluster = JSON.parse(etcd.get("/clusters/#{params[:cluster_id]}").value)
    component = Tendrl::Component.new(cluster['sds_version'],
                                      params[:object_type])

    respond_to do |f|
      f.json { component.attributes.to_json }
    end
  end

  get '/cluster/:cluster_id/:object_type/actions' do
    cluster = JSON.parse(etcd.get("/clusters/#{params[:cluster_id]}").value)
    component = Tendrl::Component.new(cluster['sds_version'],
                                      params[:object_type])

    respond_to do |f|
      f.json { component.actions.to_json }
    end
  end

  post '/cluster/:cluster_id/:object_type/:action' do
    cluster = JSON.parse(etcd.get("/clusters/#{params[:cluster_id]}").value)
    component = Tendrl::Component.new(cluster['sds_version'],
                                      params[:object_type])
    body = JSON.parse(request.body.read)
    job_id = SecureRandom.uuid
    etcd.set("/queue/#{job_id}", value: {
      cluster_id: params[:cluster_id],
        sds_nvr: cluster['sds_version'],
        action: params[:action],
        object_type: params[:object_type],
        status: 'processing',
        attributes: body.slice(*component.attributes.keys)
    }.to_json)

    job = { 
      job_id: job_id,
      status: 'processing',
      sds_nvr: cluster['sds_version'],
      action: params[:action],
      object_type: params[:object_type] 
    }

    respond_to do |f|
      status 202
      f.json { job.to_json }
    end
  end


end
