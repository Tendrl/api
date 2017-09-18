class AuthenticatedUsersController < ApplicationController

  before do
    authenticate
  end

  before do
    if ['POST', 'PUT', 'DELETE'].include? request.request_method
      unless users_path?
        halt 403, { errors: { message: 'Forbidden' } }.to_json if limited_user?
      end
    end
  end

  get '/current_user' do
    UserPresenter.single(current_user).to_json
  end

  def users_path?
    request.path_info.match(/\/users\/.+/).present?
  end

  def admin_user?
    current_user.admin?
  end

  def normal_user?
    current_user.normal?
  end

  def limited_user?
    current_user.limited?
  end

  protected

  def load_definitions(cluster_id)
    definitions = etcd.get(
      "/clusters/#{cluster_id}/_NS/definitions/data"
    ).value
    Tendrl.cluster_definitions = YAML.load(definitions)
  rescue Etcd::KeyNotFound => e
    exception = Tendrl::HttpResponseErrorHandler.new(
      e, cause: '/clusters/definitions', object_id: cluster_id
    )
    halt exception.status, exception.body.to_json
  end

  def cluster(cluster_id)
    load_definitions(cluster_id)
    @cluster ||=
      Tendrl.recurse(etcd.get("/clusters/#{cluster_id}/TendrlContext"))['tendrlcontext']
  rescue Etcd::KeyNotFound => e
    exception =  Tendrl::HttpResponseErrorHandler.new(
      e, cause: '/clusters/id', object_id: cluster_id
    )
    halt exception.status, exception.body.to_json
  end

  def authenticate
    if access_token.present?
      @current_user = Tendrl::User.authenticate_access_token(access_token)
    end
    halt 401, { errors: { message: 'Unauthorized'} }.to_json if @current_user.nil?
  end

  def current_user
    @current_user || authenticate
  end

end
