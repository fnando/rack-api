module Rack
  class API
    module Middleware
      class Limit
        attr_reader :options, :env

        def initialize(app, options = {})
          @app = app
          @options = {
            :limit  => 60,
            :key    => "REMOTE_ADDR",
            :with   => Redis.new
          }.merge(options)
        end

        def call(env)
          @env = env

          if authorized?
            @app.call(env)
          else
            [503, {"Content-Type" => "text/plain"}, ["Over Rate Limit."]]
          end
        rescue Exception => e
          @app.call(env)
        end

        private
        def authorized?
          count = redis.incr(key)
          redis.expire(key, 3600)

          count <= options[:limit] || redis.sismember("api:whitelist", identifier)
        end

        def redis
          options[:with]
        end

        def identifier
          @identifier ||= begin
            options[:key].respond_to?(:call) ? options[:key].call(env).to_s : env[options[:key].to_s]
          end
        end

        def key
          @key ||= begin
            "api:#{identifier}:#{Time.now.strftime("%Y%m%d%H")}"
          end
        end
      end
    end
  end
end
