class UsersController < AuthenticatedUsersController

  get '/users' do
    authorized?
    UserPresenter.list(Tendrl::User.all).to_json
  end

  get '/users/:username' do
    authorized? unless current_user.username == params[:username]
    user = Tendrl::User.find(params[:username])
    not_found if user.nil?
    UserPresenter.single(user).to_json
  end

  post '/users' do
    authorized?
    user_form = Tendrl::UserForm.new(
      Tendrl::User.new,
      user_attributes
    )
    if user_form.valid?
      user = Tendrl::User.save(user_form.attributes)
      status 201
      UserPresenter.single(user).to_json
    else
      status 422
      { errors: user_form.errors.messages }.to_json
    end
  end

  put '/users/:username' do
    authorized? unless current_user.username == params[:username]
    user = Tendrl::User.find(params[:username])
    not_found if user.nil?
    user_form = Tendrl::UserForm.new(user, user_attributes)
    if user_form.valid?
      attributes = user_form.attributes
      attributes[:role] = user.role # Disallow updating role
      user = Tendrl::User.save(attributes)
      UserPresenter.single(user).to_json
    else
      status 422
      { errors: user_form.errors.messages }.to_json
    end
  end

  delete '/users/:username' do
    authorized?
    user = Tendrl::User.find(params[:username])
    not_found if user.nil?
    if user.admin?
      halt 403, { errors: { message: 'Forbidden' } }.to_json
    else
      user.delete
      {}.to_json
    end
  end

  private

  def not_found
    halt 404, { errors: { message: 'Not found.' }}.to_json
  end

  def authorized?
    halt 403, { errors: { message: 'Forbidden' } }.to_json unless admin_user?
  end

  def user_attributes
    body = request.body.read
    @user_attributes ||= JSON.parse(body).symbolize_keys.slice(
      :name,
      :email,
      :username,
      :role,
      :password,
      :email_notifications
    )
  end

end
