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

  error Tendrl::HttpResponseErrorHandler do
    halt env['sinatra.error'].status, env['sinatra.error'].body.to_json
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
end
