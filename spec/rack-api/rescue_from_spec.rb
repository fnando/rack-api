require "spec_helper"

describe Rack::API, "Rescue from exceptions" do
  class NotFound < StandardError; end

  it "rescues from NotFound exception" do
    Rack::API.app do
      rescue_from NotFound, :status => 404

      version :v1 do
        get("/404") { raise NotFound }
      end
    end

    get "/v1/404"
    last_response.headers["Content-Type"].should == "text/plain"
    last_response.body.should == ""
    last_response.status.should == 404
  end

  it "rescues from all exceptions" do
    Rack::API.app do
      rescue_from Exception

      version :v1 do
        get("/500") { raise "Oops!" }
      end
    end

    get "/v1/500"
    last_response.headers["Content-Type"].should == "text/plain"
    last_response.body.should == ""
    last_response.status.should == 500
  end

  it "rescues from exception by using a block" do
    Rack::API.app do
      rescue_from Exception do
        [501, {"Content-Type" => "application/json"}, [{:error => true}.to_json]]
      end

      version :v1 do
        get("/501") { raise "Oops!" }
      end
    end

    get "/v1/501"
    last_response.headers["Content-Type"].should == "application/json"
    last_response.body.should == {:error => true}.to_json
    last_response.status.should == 501
  end

  it "rescues from exception by using inner handler" do
    Rack::API.app do
      rescue_from Exception

      version :v1 do
        rescue_from Exception do
          [500, {"Content-Type" => "text/plain"}, ["inner handler"]]
        end

        get("/500") { raise "Oops!" }
      end
    end

    get "/v1/500"
    last_response.body.should == "inner handler"
  end

  it "rescues from exception in app's context" do
    Rack::API.app do
      rescue_from Exception

      version :v1 do
        rescue_from Exception do
          [500, {"Content-Type" => "text/plain"}, [self.class.name]]
        end

        get("/500") { raise "Oops!" }
      end
    end

    get "/v1/500"
    last_response.body.should == "Rack::API::App"
  end

  it "yields the exception object" do
    Rack::API.app do
      rescue_from Exception

      version :v1 do
        rescue_from Exception do |error|
          [500, {"Content-Type" => "text/plain"}, [error.message]]
        end

        get("/500") { raise "Oops!" }
      end
    end

    get "/v1/500"
    last_response.body.should == "Oops!"
  end
end
