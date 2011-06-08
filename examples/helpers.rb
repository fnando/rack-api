$:.push(File.dirname(__FILE__) + "/../lib")

# Just run `ruby examples/basic_auth.rb` and then use something like
# `curl http://localhost:2345/api/v1/` or
# `curl http://localhost:2345/api/v1/This%20is%20so%20cool`.

require "rack/api"

Rack::API.app do
  prefix "api"

  helper do
    def default_message
      "Hello from Rack API"
    end
  end

  version :v1 do
    get "/(:message)" do
      {:message => params.fetch(:message, default_message)}
    end
  end
end

Rack::Handler::Thin.run Rack::API, :Port => 2345
