$:.push(File.dirname(__FILE__) + "/../lib")

# Just run `ruby examples/multiple_versions.rb` and then use something like
# `curl http://localhost:2345/api/v1/` and `curl http://localhost:2345/api/v2`.

require "rack/api"

Rack::API.app do
  prefix "api"

  version :v1 do
    get "/" do
      {:message => "You're using API v1"}
    end
  end

  version :v2 do
    get "/" do
      {:message => "You're using API v2"}
    end
  end
end

Rack::Handler::Thin.run Rack::API, :Port => 2345
