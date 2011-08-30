require "bundler"
Bundler.setup(:default, :development)
Bundler.require

require "rack/test"
require "rspec"
require "rack/api"
require "base64"
require "redis"
require "ostruct"

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|file| require file}

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include Helpers

  config.before { Rack::API.reset! }
end
