ENV['RACK_ENV'] = 'test'

require_relative File.join('..', 'base')
require './lib/tendrl'

RSpec.configure do |config|
  include Rack::Test::Methods
end
