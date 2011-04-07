module Rack
  class API
    module Formatter
      class Jsonp < Base
        def to_format
          params.fetch(:callback, "callback") + "(#{object.to_json});"
        end
      end
    end
  end
end
