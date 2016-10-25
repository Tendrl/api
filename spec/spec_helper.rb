ENV['RACK_ENV'] = 'test'

require_relative File.join('..', 'app')
require './lib/tendrl'

RSpec.configure do |config|
  include Rack::Test::Methods

  Tendrl.sds_config('spec/fixtures/sds')

  def app
    App
  end
end
