class UsersController < AuthenticatedUsersController

  before '/users/*'do
    halt 403, { errors: { message: 'Forbidden' } }.to_json unless admin_user?
  end

  get '/users' do
    UserPresenter.list(Tendrl::User.all).to_json
  end

  get '/users/:username' do
    user = Tendrl::User.find(params[:username])
    UserPresenter.single(user).to_json
  end

  post '/users' do
    user_validator = Tendrl::Validator::UserValidator.new(
      Tendrl::User.new,
      user_attributes
    )
    if user_validator.valid?
      user = Tendrl::User.save(user_validator.attributes)
      status 201
      UserPresenter.single(user).to_json
    else
      status 400
      { errors: user_validator.errors.full_messages }.to_json
    end
  end

  put '/users/:username' do
    user = Tendrl::User.find(params[:username])
    user_validator = Tendrl::Validator::UserValidator.new(
      user,
      user_attributes)
    if user_validator.valid?
      user = Tendrl::User.save(user_validator.attributes)
      UserPresenter.single(user).to_json
    else
      status 400
      { errors: user_validator.errors.full_messages }.to_json
    end
  end

  delete '/users/:username' do
    Tendrl::User.find(params[:username]).delete
    {}.to_json
  end

  private

  def user_attributes
    body = request.body.read
    @user_attributes ||= JSON.parse(body).symbolize_keys.slice(
      :name,
      :email,
      :username,
      :role,
      :password,
      :password_confirmation
    )
  end

end
