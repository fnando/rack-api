$:.push(File.dirname(__FILE__) + "/../lib")

# Just run `ruby examples/middleware.rb` and then use something like
# `curl http://localhost:2345/api/v1/`.

require "rack/api"
require "json"

class ResponseTime
  def initialize(app)
    @app = app
  end

  def call(env)
    start = Time.now
    status, headers, response = @app.call(env)
    elapsed = Time.now - start
    response = JSON.load(response.first).merge(:response_time => elapsed)
    [status, headers, [response.to_json]]
  end
end

Rack::API.app do
  prefix "api"
  use ResponseTime

  version :v1 do
    get "/" do
      {:message => "Hello, awesome API!"}
    end
  end
end

Rack::Handler::Thin.run Rack::API, :Port => 2345
