$:.push(File.dirname(__FILE__) + "/../lib")

# Just run `ruby examples/basic_auth.rb` and then use something like
# `curl -u admin:test http://localhost:2345/api/v1/`.

require "rack/api"

Rack::API.app do
  prefix "api"

  basic_auth do |user, pass|
    user == "admin" && pass == "test"
  end

  version :v1 do
    get "/" do
      {:message => "Hello, awesome API!"}
    end
  end
end

Rack::Handler::Thin.run Rack::API, :Port => 2345
