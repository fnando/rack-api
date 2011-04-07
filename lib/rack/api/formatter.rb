module Rack
  class API
    module Formatter
      autoload :Base, "rack/api/formatter/base"
      autoload :Jsonp, "rack/api/formatter/jsonp"
    end
  end
end
