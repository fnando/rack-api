module Rack
  class API
    module Middleware
      class Format
        def initialize(app, formats)
          @app, @formats = app, formats.collect {|f| f.to_s}
        end

        def call(env)
          request = Rack::Request.new(env)
          params = request.env["rack.routing_args"].merge(request.params)
          requested_format = params.fetch(:format, "json")

          if @formats.include?(requested_format)
            @app.call(env)
          else
            [406, {"Content-Type" => "text/plain"}, ["Invalid format"]]
          end
        end
      end
    end
  end
end
