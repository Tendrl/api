$:.unshift(File.expand_path("../lib", __FILE__))
require './app/controllers/application_controller'
require './app/controllers/authenticated_users_controller'
require './app/controllers/ping_controller'
require './app/controllers/nodes_controller'
require './app/controllers/clusters_controller'
require './app/controllers/jobs_controller'
require './app/controllers/users_controller'
require './app/controllers/sessions_controller'
require './app/controllers/monitoring_controller'
require './app/controllers/alerting_controller'
require './app/controllers/notifications_controller'

map('/1.0') { 
  use PingController
  use SessionsController
  use MonitoringController
  use AlertingController
  use NotificationsController
  use JobsController
  use UsersController
  use ClustersController
  use NodesController
  use AuthenticatedUsersController
  run ApplicationController
}
