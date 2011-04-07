require "spec_helper"

describe Rack::API, "Short circuit" do
  before do
    Rack::API.app do
      version :v1 do
        get("/") { error :status => 412, :headers => {"X-Awesome" => "UR NO Awesome"}, :message => "ZOMG! Nothing to see here!" }
        get("/custom") do
          error_message = Object.new
          def error_message.to_rack
            [412, {"X-Awesome" => "UR NO Awesome Indeed"}, ["Keep going!"]]
          end

          error(error_message)
        end
      end
    end
  end

  it "renders hash error" do
    get "/v1"
    last_response.status.should == 412
    last_response.headers["X-Awesome"].should == "UR NO Awesome"
    last_response.body.should == "ZOMG! Nothing to see here!"
  end

  it "renders object#to_rack method" do
    get "/v1/custom"
    last_response.status.should == 412
    last_response.headers["X-Awesome"].should == "UR NO Awesome Indeed"
    last_response.body.should == "Keep going!"
  end
end
