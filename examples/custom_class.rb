$:.push(File.dirname(__FILE__) + "/../lib")

# Just run `ruby examples/custom_class.rb` and then use something like
# `curl http://localhost:2345/api/v1/` and `curl http://localhost:2345/api/v2/`.

require "rack/api"

class MyApp < Rack::API
  prefix "api"

  version :v1 do
    get "/" do
      {:message => "Using API v1"}
    end
  end
end

class MyApp < Rack::API
  prefix "api"

  version :v2 do
    get "/" do
      {:message => "Using API v2"}
    end
  end
end

Rack::Handler::Thin.run MyApp, :Port => 2345
