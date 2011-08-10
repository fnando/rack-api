module Rack
  class API
    module Formatter
      class Base
        attr_accessor :object
        attr_accessor :params
        attr_accessor :env

        class AbstractMethodError < StandardError; end

        def initialize(object, env, params)
          @object, @env, @params = object, env, params
        end

        def to_format
          raise AbstractMethodError
        end
      end
    end
  end
end
