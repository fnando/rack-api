module Rack
  class API
    class App
      # Registered content types. If you want to use
      # a custom formatter that is not listed here,
      # you have to manually add it. Otherwise,
      # Rack::API::App::DEFAULT_MIME_TYPE will be used
      # as the content type.
      #
      MIME_TYPES = {
        "json"  => "application/json",
        "jsonp" => "application/javascript",
        "xml"   => "application/xml",
        "rss"   => "application/rss+xml",
        "atom"  => "application/atom+xml",
        "html"  => "text/html",
        "yaml"  => "application/x-yaml",
        "txt"   => "text/plain"
      }

      # Default content type. Will be used when a given format
      # hasn't been registered on Rack::API::App::MIME_TYPES.
      #
      DEFAULT_MIME_TYPE = "application/octet-stream"

      attr_reader :block
      attr_reader :env

      # Hold block that will be executed in case the
      # route is recognized.
      #
      def initialize(options)
        options.each do |name, value|
          instance_variable_set("@#{name}", value)
        end
      end

      # Always log to the standard output.
      #
      def logger
        @logger ||= Logger.new(STDOUT)
      end

      # Hold headers that will be sent on the response.
      #
      def headers
        @headers ||= {}
      end

      # Merge all params into one single hash.
      #
      def params
        @params ||= HashWithIndifferentAccess.new(request.params.merge(env["rack.routing_args"]))
      end

      # Return a request object.
      #
      def request
        @request ||= Rack::Request.new(env)
      end

      # Return the requested format. Defaults to JSON.
      #
      def format
        params.fetch(:format, "json")
      end

      # Stop processing by rendering the provided information.
      #
      #   Rack::API.app do
      #     version :v1 do
      #       get "/" do
      #         error(:status => 403, :message => "Not here!")
      #       end
      #     end
      #   end
      #
      # Valid options are:
      #
      # # <tt>:status</tt>: a HTTP status code. Defaults to 403.
      # # <tt>:message</tt>: a message that will be rendered as the response body. Defaults to "Forbidden".
      # # <tt>:headers</tt>: the response headers. Defaults to <tt>{"Content-Type" => "text/plain"}</tt>.
      #
      # You can also provide a object that responds to <tt>to_rack</tt>. In this case, this
      # method must return a valid Rack response (a 3-item array).
      #
      #   class MyError
      #     def self.to_rack
      #       [500, {"Content-Type" => "text/plain"}, ["Internal Server Error"]]
      #     end
      #   end
      #
      #   Rack::API.app do
      #     version :v1 do
      #       get "/" do
      #         error(MyError)
      #       end
      #     end
      #   end
      #
      def error(options = {})
        throw :error, Response.new(options)
      end

      # Set response status code.
      #
      def status(*args)
        @status = args.first unless args.empty?
        @status || 200
      end

      # Reset environment between requests.
      #
      def reset! # :nodoc:
        @params = nil
        @request = nil
        @headers = nil
      end

      # Return credentials for Basic Authentication request.
      #
      def credentials
        @credentials ||= begin
          request = Rack::Auth::Basic::Request.new(env)
          request.provided? ? request.credentials : []
        end
      end

      # Render the result of block.
      #
      def call(env) # :nodoc:
        reset!
        @env = env

        response = catch(:error) do
          render instance_eval(&block)
        end

        response.respond_to?(:to_rack) ? response.to_rack : response
      end

      # Return response content type based on extension.
      # If you're using an unknown extension that wasn't registered on
      # Rack::API::App::MIME_TYPES, it will return Rack::API::App::DEFAULT_MIME_TYPE,
      # which defaults to <tt>application/octet-stream</tt>.
      #
      def content_type
        mime = MIME_TYPES.fetch(format, DEFAULT_MIME_TYPE)
        headers.fetch("Content-Type", mime)
      end

      private
      def render(response) # :nodoc:
        [status, headers.merge("Content-Type" => content_type), [format_response(response)]]
      end

      def format_response(response) # :nodoc:
        formatter_name = format.split("_").collect {|word| word[0,1].upcase + word[1,word.size].downcase}.join("")

        if Rack::API::Formatter.const_defined?(formatter_name)
          formatter = Rack::API::Formatter.const_get(formatter_name).new(response, params)
          formatter.to_format
        elsif response.respond_to?("to_#{format}")
          response.__send__("to_#{format}")
        else
          throw :error, Response.new(:status => 406, :message => "Unknown format")
        end
      end
    end
  end
end
