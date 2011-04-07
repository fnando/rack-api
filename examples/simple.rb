$:.push(File.dirname(__FILE__) + "/../lib")

# Just run `ruby examples/simple.rb` and then use something like
# `curl http://localhost:2345/api/v1/`.

require "rack/api"

Rack::API.app do
  prefix "api"

  version :v1 do
    get "/" do
      {:message => "Hello, awesome API!"}
    end
  end
end

Rack::Handler::Thin.run Rack::API, :Port => 2345
