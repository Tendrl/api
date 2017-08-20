class UsersController < AuthenticatedUsersController

  before '/users/*'do
    halt 403, { errors: { message: 'Forbidden' } }.to_json unless admin_user?
  end

  get '/users' do
    UserPresenter.list(Tendrl::User.all).to_json
  end

  get '/users/:username' do
    user = Tendrl::User.find(params[:username])
    if user
      UserPresenter.single(user).to_json
    else
      halt 404, { errors: { message: 'Not found.' }}.to_json
    end
  end

  post '/users' do
    user_form = Tendrl::UserForm.new(
      Tendrl::User.new,
      user_attributes
    )
    if user_form.valid?
      user = Tendrl::User.save(user_form.attributes)
      status 201
      UserPresenter.single(user).to_json
    else
      status 400
      { errors: user_form.errors.messages }.to_json
    end
  end

  put '/users/:username' do
    user = Tendrl::User.find(params[:username])
    user_form = Tendrl::UserForm.new(user, user_attributes)
    if user_form.valid?
      user = Tendrl::User.save(user_form.attributes)
      UserPresenter.single(user).to_json
    else
      status 400
      { errors: user_form.errors.messages }.to_json
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
