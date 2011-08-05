$:.push(File.dirname(__FILE__) + "/../lib")

# Just run `ruby examples/controller.rb` and then use something like
# `curl http://localhost:2345/api/v1/`.

require "rack/api"

class Hello < Rack::API::Controller
  def index
    {:message => "Hello, awesome API!"}
  end
end

Rack::API.app do
  prefix "api"

  version :v1 do
    get "/", :to => "hello#index"
  end
end

Rack::Handler::Thin.run Rack::API, :Port => 2345
