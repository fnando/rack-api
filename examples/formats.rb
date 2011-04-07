$:.push(File.dirname(__FILE__) + "/../lib")

# Just run `ruby examples/formats.rb` and then use something like
# `curl http://localhost:2345/api/v1/hello.json` or
# `curl http://localhost:2345/api/v1/hello.jsonp?callback=myJSHandler`.

require "rack/api"

Rack::API.app do
  prefix "api"

  version :v1 do
    get "/hello(.:format)" do
      {:message => "Hello from Rack API"}
    end
  end
end

Rack::Handler::Thin.run Rack::API, :Port => 2345
