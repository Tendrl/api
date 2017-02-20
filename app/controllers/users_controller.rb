class UsersController < AuthenticatedUsersController

  before '/users'do
    halt 403 unless admin_user?
  end

  get '/users' do
  end

  get '/users/:id' do
  end

  post '/users' do
  end

  put '/users/:id' do
  end

  delete '/users/:id' do
  end

end
