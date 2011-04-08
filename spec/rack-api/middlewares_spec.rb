require "spec_helper"

describe Rack::API, "Middlewares" do
   before do
    Rack::API.app do
      use ZOMGMiddleware

      version :v1 do
        use AwesomeMiddleware
        get("/") {}
      end
    end
  end

  it "sends custom headers" do
    get "/v1"
    last_response.headers["X-Awesome"].should == "U R Awesome"
    last_response.headers["X-ZOMG"].should == "ZOMG!"
  end
end
