class AuthenticatedUsersController < ApplicationController

  before do
    authenticate
  end

  before do
    if ['POST', 'PUT', 'DELETE'].include? request.request_method
      halt 403 if limited_user?
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
    if username.present? && access_token.present?
      @current_user = Tendrl::User.authenticate_access_token(
        username,
        access_token
      )
    end
    halt 401 if @current_user.nil?
  end

  def current_user
    @current_user || authenticate
  end

  def monitoring
    config = recurse(etcd.get('/_tendrl/config/performance_monitoring/data'))
    @monitoring = Tendrl::MonitoringApi.new(config['data'])
  rescue Etcd::KeyNotFound
    logger.info 'Monitoring API not enabled.'
    nil
  end

end
