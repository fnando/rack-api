module Rack
  class API
    module Middleware
      autoload :Format, "rack/api/middleware/format"
      autoload :SSL, "rack/api/middleware/ssl"
      autoload :Limit, "rack/api/middleware/limit"
    end
  end
end
