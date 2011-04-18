require "spec_helper"

describe Rack::API, "Headers" do
   before do
    Rack::API.app do
      version :v1 do
        get("/users(.:format)") do
          headers["X-Awesome"] = "U R Awesome"
          headers["Content-Type"] = "application/x-json" # the default json header is application/json
        end
      end
    end
  end

  it "sends custom headers" do
    get "/v1/users"
    last_response.headers["X-Awesome"].should == "U R Awesome"
  end

  it "overrides inferred content type" do
    get "/v1/users.json"
    last_response.headers["Content-Type"].should == "application/x-json"
  end
end
