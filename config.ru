$:.unshift(File.expand_path("../lib", __FILE__))
require './node'
require './cluster'

map('/1.0') { 
  use Node
  run Cluster
}
