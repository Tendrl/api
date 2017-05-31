class SessionsController < ApplicationController

  post '/login' do
    body = request.body.read
    attributes = JSON.parse(body).symbolize_keys

    user = Tendrl::User.authenticate(attributes[:username],
                                     attributes[:password])
    if user.present?
      { access_token: user.generate_token }.to_json
    else
      status 401
      { errors: { message: 'Incorrect username or password.' } }.to_json
    end
  end

  # TODO move to different controller under AuthenticatedUsersController
  delete '/logout' do
    user = Tendrl::User.authenticate_access_token(access_token)
    if user
      user.delete_token(access_token)
      {}.to_json
    else
      halt 401, { errors: { message: 'Unauthorized'} }.to_json
    end
  end

end
