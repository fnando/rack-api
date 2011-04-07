require "spec_helper"

describe Rack::API, "Middlewares" do
   before do
    Rack::API.app do
      version :v1 do
        use AwesomeMiddleware
        get("/") {}
      end
    end
  end

  it "sends custom headers" do
    get "/v1"
    last_response.headers["X-Awesome"].should == "U R Awesome"
  end
end
