module Rack
  class API
    class Response
      attr_reader :options

      def initialize(options)
        @options = options
      end

      def to_rack
        return options.to_rack if options.respond_to?(:to_rack)

        [
          options.fetch(:status, 403),
          {"Content-Type" => "text/plain"}.merge(options.fetch(:headers, {})),
          [options.fetch(:message, "Forbidden")]
        ]
      end
    end
  end
end
