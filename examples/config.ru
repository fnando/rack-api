$:.push(File.dirname(__FILE__) + "/../lib")

# Just run `rackup -p 2345` and then use something like
# `curl -u admin:test http://localhost:2345/`.
#
# You can also use Thin. Just run it with `thin -R config.ru -p 2345 -DV start`.
#

require "rack/api"

class Sample < Rack::API
  get "/" do
    {:message => "Hello World, from Rack!"}
  end
end

run Sample
