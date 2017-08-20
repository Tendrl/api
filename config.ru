$:.unshift(File.expand_path("../lib", __FILE__))

require 'tendrl'

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
