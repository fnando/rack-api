module Rack
  class API
    class Runner
      HTTP_METHODS = %w[get post put delete head]

      DELEGATE_METHODS = %w[
        version use prefix basic_auth
        helper respond_to default_url_options
      ]

      attr_accessor :settings

      def initialize
        @settings = {
          :middlewares => [],
          :helpers => [],
          :global => {
            :prefix      => "/",
            :formats     => %w[json jsonp],
            :middlewares => [],
            :helpers     => []
          }
        }
      end

      # Set configuration based on scope. When defining values outside version block,
      # will set configuration using <tt>settings[:global]</tt> namespace.
      #
      # Use the Rack::API::Runner#option method to access a given setting.
      #
      def set(name, value, mode = :override)
        target = settings[:version] ? settings : settings[:global]

        if mode == :override
          target[name] = value
        else
          target[name] << value
        end
      end

      # Try to fetch local configuration, defaulting to the global setting.
      # Return +nil+ when no configuration is defined.
      #
      def option(name, mode = :any)
        if mode == :merge && (settings[name].kind_of?(Array) || settings[:global][name].kind_of?(Array))
          settings[:global].fetch(name, []) | settings.fetch(name, [])
        else
          settings.fetch(name, settings[:global][name])
        end
      end

      # Add a middleware to the execution stack.
      #
      # Global middlewares will be merged with local middlewares.
      #
      #   Rack::API.app do
      #     use ResponseTime
      #
      #     version :v1 do
      #       use Gzip
      #     end
      #   end
      #
      # The middleware stack will be something like <tt>[ResponseTime, Gzip]</tt>.
      #
      def use(middleware, *args)
        set :middlewares, [middleware, *args], :append
      end

      # Set an additional url prefix.
      #
      def prefix(name)
        set :prefix, name
      end

      # Add a helper to application.
      #
      #   helper MyHelpers
      #   helper {  }
      #
      def helper(mod = nil, &block)
        mod = Module.new(&block) if block_given?
        raise ArgumentError, "you need to pass a module or block" unless mod
        set :helpers, mod, :append
      end

      # Define the server endpoint. Will be used if you call the method
      # Rack::API::App#url_for.
      #
      # The following options are supported:
      #
      # * <tt>:host</tt> – Specifies the host the link should be targeted at.
      # * <tt>:protocol</tt> – The protocol to connect to. Defaults to 'http'.
      # * <tt>:port</tt> – Optionally specify the port to connect to.
      # * <tt>:base_path</tt> – Optionally specify a base path.
      #
      # Some usage examples:
      #
      #   default_url_options :host => "myhost.com"
      #   #=> http://myhost.com
      #
      #   default_url_options :host => "myhost.com", :protocol => "https"
      #   #=> https://myhost.com
      #
      #   default_url_options :host => "myhost.com", :port => 3000
      #   #=> http://myhost.com:3000
      #
      #   default_url_options :host => "myhost.com", :base_path => "my/custom/path"
      #   #=> http://myhost.com/my/custom/path
      #
      def default_url_options(options)
        set :url_options, options
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
      #
      # You can disable basic authentication by providing <tt>:none</tt> as
      # realm.
      #
      #   Rack::API.app do
      #     basic_auth "Protected Area" do |user, pass|
      #       User.authenticate(user, pass)
      #     end
      #
      #     version :v1 do
      #       # this version is protected by the
      #       # global basic auth block above.
      #     end
      #
      #     version :v2 do
      #       basic_auth :none
      #       # this version is now public
      #     end
      #
      #     version :v3 do
      #       basic_auth "Admin" do |user, pass|
      #         user == "admin" && pass == "test"
      #       end
      #     end
      #   end
      #
      def basic_auth(realm = "Restricted Area", &block)
        set :auth, (realm == :none ? :none : [realm, block])
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
      # Local formats will override the global configuration on that context.
      #
      #   Rack::API.app do
      #     respond_to :json, :xml, :jsonp
      #
      #     version :v1 do
      #       respond_to :json
      #     end
      #   end
      #
      # The code above will accept only <tt>:json</tt> as format on version <tt>:v1</tt>.
      #
      # Also, the first value provided to this method will be used as default format,
      # which means that requests that don't provide the <tt>:format</tt> param, will use
      # this value.
      #
      #   respond_to :fffuuu, :json
      #   #=> the default format is fffuuu
      #
      def respond_to(*formats)
        set :formats, formats
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

      private
      def mount_path(path) # :nodoc:
        Rack::Mount::Utils.normalize_path([option(:prefix), settings[:version], path].join("/"))
      end

      def default_format # :nodoc:
        (option(:formats).first || "json").to_s
      end

      def build_app(handler) # :nodoc:
        app = App.new({
          :handler        => handler,
          :default_format => default_format,
          :version        => option(:version),
          :prefix         => option(:prefix),
          :url_options    => option(:url_options)
        })

        builder = Rack::Builder.new

        # Add middleware for basic authentication.
        auth = option(:auth)
        builder.use Rack::Auth::Basic, auth[0], &auth[1] if auth && auth != :none

        # Add middleware for format validation.
        builder.use Rack::API::Middleware::Format, default_format, option(:formats)

        # Add middlewares to executation stack.
        option(:middlewares, :merge).each {|middleware| builder.use(*middleware)}

        # Apply helpers to app.
        helpers = option(:helpers)
        app.extend *helpers unless helpers.empty?

        builder.run(app)
        builder.to_app
      end
    end
  end
end
