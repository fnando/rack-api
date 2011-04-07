$:.push(File.dirname(__FILE__) + "/../lib")

# Just run `ruby examples/params.rb` and then use something like
# `curl http://localhost:2345/api/v1/hello/John`.

require "rack/api"

Rack::API.app do
  prefix "api"

  version :v1 do
    get "/hello/:name" do
      {:message => "Hello, #{params[:name]}"}
    end
  end
end

Rack::Handler::Thin.run Rack::API, :Port => 2345
