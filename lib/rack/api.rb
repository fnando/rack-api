require "rack"
require "rack/mount"
require "active_support/hash_with_indifferent_access"
require "active_support/core_ext/object/to_query"
require "json"
require "logger"
require "forwardable"

module Rack
  class API
    autoload :App         , "rack/api/app"
    autoload :Formatter   , "rack/api/formatter"
    autoload :Middleware  , "rack/api/middleware"
    autoload :Runner      , "rack/api/runner"
    autoload :Response    , "rack/api/response"
    autoload :Version     , "rack/api/version"

    class << self
      extend Forwardable

      def_delegators :runner, :version, :use, :prefix, :basic_auth, :helper, :respond_to
    end

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
