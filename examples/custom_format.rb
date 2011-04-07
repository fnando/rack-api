$:.push(File.dirname(__FILE__) + "/../lib")

# Just run `ruby examples/formats.rb` and then use something like
# `curl http://localhost:2345/api/v1/hello.xml`.

require "rack/api"
require "active_support/all"

module Rack
  class API
    module Formatter
      class Xml < Base
        def to_format
          object.to_xml(:root => :messages)
        end
      end
    end
  end
end

Rack::API.app do
  prefix "api"
  respond_to :xml

  version :v1 do
    get "/hello(.:format)" do
      {:message => "Hello from Rack API"}
    end
  end
end

Rack::Handler::Thin.run Rack::API, :Port => 2345
