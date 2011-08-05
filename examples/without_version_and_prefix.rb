$:.push(File.dirname(__FILE__) + "/../lib")

# Just run `ruby examples/without_version_and_prefix.rb` and then use something like
# `curl http://localhost:2345/`.

require "rack/api"

Rack::API.app do
  get "/" do
    {:message => "Hello, awesome API!"}
  end
end

Rack::Handler::Thin.run Rack::API, :Port => 2345
