class PingController < ApplicationController

  get '/ping' do
    {
      status: 'Ok'
    }.to_json
  end

end
