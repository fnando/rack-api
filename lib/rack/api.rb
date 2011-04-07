require "rack"
require "rack/mount"
require "active_support/hash_with_indifferent_access"
require "json"
require "logger"

module Rack
  class API
    autoload :App, "rack/api/app"
    autoload :Formatter, "rack/api/formatter"
    autoload :Runner, "rack/api/runner"
    autoload :Response, "rack/api/response"
    autoload :Version, "rack/api/version"

    # A shortcut for defining new APIs. Instead of creating a
    # class that inherits from Rack::API, you can simply pass a
    # block to the Rack::API.app method.
    #
    #   Rack::API.app do
    #     # define your API
    #   end
    #
    def self.app(&block)
      runner.instance_eval(&block)
      runner
    end

    # Add a middleware to the stack execution.
    #
    #   Rack::API.app do
    #     use MyMiddleware
    #   end
    #
    def self.use(m)
      runner.use(m)
    end

    # Create a new API version.
    #
    #   Rack::API.app do
    #     version "v1" do
    #       # define your API
    #     end
    #   end
    #
    def self.version(name, &block)
      runner.version(name, &block)
    end

    # Set an additional url prefix.
    #
    #   Rack::API.app do
    #     prefix "api"
    #     version("v1") {}
    #   end
    #
    # This API will be available through <tt>/api/v1</tt> path.
    #
    def self.prefix(name)
      runner.prefix(name)
    end

    # Reset all API definitions while using the Rack::API.app method.
    #
    def self.reset!
      @runner = nil
    end

    # Required by Rack.
    #
    def self.call(env) # :nodoc:
      runner.call(env)
    end

    private
    # Initialize a new Rack::API::Middleware instance, so
    # we can use it on other class methods.
    #
    def self.runner
      @runner ||= Runner.new
    end
  end
end
