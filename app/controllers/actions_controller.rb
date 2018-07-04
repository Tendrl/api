class ActionsController < AuthenticatedUsersController
  before '/clusters/:cluster_id/?*?' do
    begin
      @cluster = Tendrl::Cluster.find(params[:cluster_id])
    rescue Etcd::KeyNotFound => e
      e = Tendrl::HttpResponseErrorHandler.new(
        e, cause: '/clusters/id', object_id: params[:cluster_id]
      )
      halt e.status, e.body.to_json
    end
  end

  get '/clusters/:cluster_id' do
    ClusterPresenter.single(Tendrl::Cluster.find(params[:cluster_id])).to_json
  end

  post '/clusters/:cluster_id/jobs' do
    HTTParty.post("http://localhost:8000/clusters/#{cluster_id}/jobs", body: { shell: 'echo "foobar"'}.to_json)
  end
end
