$:.push(File.dirname(__FILE__) + "/../lib")

# Just run `ruby examples/simple.rb` and then use something like
# `curl http://localhost:2345/api/v1/`.

require "rack/api"
require "logger"

$logger = Logger.new(STDOUT)

# Simulate ActiveRecord's exception.
module ActiveRecord
  class RecordNotFound < StandardError
  end
end

Rack::API.app do
  prefix "api"

  rescue_from ActiveRecord::RecordNotFound, :status => 404
  rescue_from Exception do |error|
    $logger.error error.message
    [500, {"Content-Type" => "text/plain"}, []]
  end

  version :v1 do
    get "/" do
      raise "Oh no! Something is really wrong!"
    end
  end
end

Rack::Handler::Thin.run Rack::API, :Port => 2345
