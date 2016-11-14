require './node'
require './cluster'

map('/1.0') { 
  use Node
  run Cluster
}
