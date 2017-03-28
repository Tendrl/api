class AuthenticatedUsersController < ApplicationController

  before do
    authenticate
  end

  before do
    if ['POST', 'PUT', 'DELETE'].include? request.request_method
      halt 403, { errors: { message: 'Forbidden' } }.to_json if limited_user?
    end
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

  def authenticate
    if access_token.present?
      @current_user = Tendrl::User.authenticate_access_token(access_token)
    end
    halt 401, { errors: { message: 'Unauthorized'} }.to_json if @current_user.nil?
  end

  def current_user
    @current_user || authenticate
  end

  def monitoring
    config = recurse(etcd.get(
      '/_NS/performance_monitoring/config/data'
    ))
    @monitoring = Tendrl::MonitoringApi.new(config['data'])
  rescue Etcd::KeyNotFound
    logger.info 'Monitoring API not enabled.'
    nil
  end

end
