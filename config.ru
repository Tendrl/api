$:.unshift(File.expand_path("../lib", __FILE__))

require 'tendrl'

if ENV['ENABLE_PROFILING']
  if ENV['RACK_ENV'] == 'production'
    path = '/var/lib/tendrl/profiling/api'
  else
    path = './tmp/profiling'
  end
  require 'ruby-prof'
  use Rack::RubyProf, path: path
end

map('/1.0') { 
  use PingController
  use SessionsController
  use AlertingController
  use NotificationsController
  use JobsController
  use UsersController
  use NodesController
  use ClustersController
  use AuthenticatedUsersController
  run ApplicationController
}

#map('/2.0') do
  #use ObjectsController
  #run ApplicationController
#end
