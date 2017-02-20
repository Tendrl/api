class PingController < AuthenticatedUsersController

  before do
    authenticate
  end

  get '/ping' do
    { 
      status: 'Ok'
    }.to_json
  end

end
