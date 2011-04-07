require "rack/test"
require "rspec"
require "rack/api"
require "base64"

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|file| require file}

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include Helpers

  config.before { Rack::API.reset! }
end
