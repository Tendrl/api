class AlertingController < AuthenticatedUsersController

  get '/alerts' do
    begin
      alerts = Tendrl::Alert.all
      alerts.to_json
    rescue Etcd::KeyNotFound
      [].to_json
    end
  end

  get '/alerts/:alert_id' do
    Tendrl::Alert.find(params[:alert_id]).to_json
  end

  get '/clusters/:cluster_id/alerts' do
    Tendrl::Alert.all("clusters/#{params[:cluster_id]}").to_json
  end

  get '/nodes/:node_id/alerts' do
    Tendrl::Alert.all("nodes/#{params[:node_id]}").to_json
  end

end
