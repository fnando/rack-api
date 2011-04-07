module Rack
  class API
    class Runner
      HTTP_METHODS = %w[get post put delete head]

      attr_accessor :settings

      def initialize
        @settings = {
          :prefix      => "/",
          :formats     => %w[json jsonp],
          :middlewares => []
        }
      end

      # Add a middleware to the execution stack.
      #
      def use(middleware, *args)
        settings[:middlewares] << [middleware, *args]
      end

      # Set an additional url prefix.
      #
      def prefix(name)
        settings[:prefix] = name
      end

      # Create a new API version.
      #
      def version(name, &block)
        raise ArgumentError, "you need to pass a block" unless block_given?
        settings[:version] = name.to_s
        instance_eval(&block)
        settings.delete(:version)
      end

      # Run all routes.
      #
      def call(env) # :nodoc:
        route_set.freeze.call(env)
      end

      # Require basic authentication before processing other requests.
      # The authentication reques must be defined before routes.
      #
      #   Rack::API.app do
      #     basic_auth "Protected Area" do |user, pass|
      #       User.authenticate(user, pass)
      #     end
      #   end
      def basic_auth(realm = "Restricted Area", &block)
        settings[:auth] = [realm, block]
      end

      # Define the formats that this app implements.
      # Respond only to <tt>:json</tt> by default.
      #
      # When setting a format you have some alternatives on how this object
      # will be formated.
      #
      # First, Rack::API will look for a formatter defined on Rack::API::Formatter
      # namespace. If there's no formatter, it will look for a method <tt>to_<format></tt>.
      # It will raise an exception if no formatter method has been defined.
      #
      # See Rack::API::Formatter::Jsonp for an example on how to create additional
      # formatters.
      #
      def respond_to(*formats)
        settings[:formats] = formats
      end

      # Hold all routes.
      #
      def route_set # :nodoc:
        @route_set ||= Rack::Mount::RouteSet.new
      end

      # Define a new routing that will be triggered when both request method and
      # path are recognized.
      #
      # You're better off using all verb shortcut methods. Implemented verbs are
      # +get+, +post+, +put+, +delete+ and +head+.
      #
      #   class MyAPI < Rack::API
      #     version "v1" do
      #       get "users(.:format)" do
      #         # do something
      #       end
      #     end
      #   end
      #
      def route(method, path, requirements = {}, &block)
        path = Rack::Mount::Strexp.compile mount_path(path), requirements, %w[ / . ? ]
        route_set.add_route(build_app(block), :path_info => path, :request_method => method)
      end

      HTTP_METHODS.each do |method|
        class_eval <<-RUBY, __FILE__, __LINE__
          def #{method}(*args, &block)                # def get(*args, &block)
            route("#{method.upcase}", *args, &block)  #   route("GET", *args, &block)
          end                                         # end
        RUBY
      end

      def mount_path(path) # :nodoc:
        Rack::Mount::Utils.normalize_path([settings[:prefix], settings[:version], path].join("/"))
      end

      def build_app(block) # :nodoc:
        builder = Rack::Builder.new
        builder.use Rack::Auth::Basic, settings[:auth][0], &settings[:auth][1] if settings[:auth]
        settings[:middlewares].each {|middleware| builder.use(*middleware)}
        builder.run App.new(:block => block)
        builder.to_app
      end
    end
  end
end
