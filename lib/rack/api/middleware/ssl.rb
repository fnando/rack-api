module Rack
  class API
    module Middleware
      class SSL
        def initialize(app)
          @app = app
        end

        def call(env)
          request = Rack::Request.new(env)

          if env["rack.url_scheme"] == "https"
            @app.call(env)
          else
            [400, {"Content-Type" => "text/plain"}, ["Only HTTPS requests are supported by now."]]
          end
        end
      end
    end
  end
end
