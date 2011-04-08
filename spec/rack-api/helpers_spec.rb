require "spec_helper"

describe Rack::API, "Helpers" do
  before do
    Rack::API.app do
      version :v1 do
        helper Module.new {
          def helper_from_module
            "module"
          end
        }

        helper do
          def helper_from_block
            "block"
          end
        end

        get("/") { [helper_from_block, helper_from_module] }
      end
    end
  end

  it "adds module helper" do
    get "/v1"
    json(last_response.body).should include("module")
  end

  it "adds block helper" do
    get "/v1"
    json(last_response.body).should include("block")
  end
end
