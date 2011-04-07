module Rack
  class API
    module Formatter
      class Base
        attr_accessor :object
        attr_accessor :params

        class AbstractMethodError < StandardError; end

        def initialize(object, params)
          @object, @params = object, params
        end

        def to_format
          raise AbstractMethodError
        end
      end
    end
  end
end
