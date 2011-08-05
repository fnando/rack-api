$:.push(File.dirname(__FILE__) + "/../lib")

# Just run `ruby examples/basic_auth.rb` and then use something like
# `curl -u admin:test http://localhost:2345/api/v1/`.

require "rack/api"

class Sample < Rack::API
  get "/" do
    {:message => "Hello World, from Rack!"}
  end
end

run Sample
