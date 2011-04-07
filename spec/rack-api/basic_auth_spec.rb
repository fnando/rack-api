require "spec_helper"

describe Rack::API, "Basic Authentication" do
   before do
    Rack::API.app do
      version :v1 do
        basic_auth do |user, pass|
          user == "admin" && pass == "test"
        end

        get("/") { {:success => true} }
      end
    end
  end

  it "denies access" do
    get "/v1/"
    last_response.status.should == 401

    get "/v1/", {}, "HTTP_AUTHORIZATION" => basic_auth("admin", "invalid")
    last_response.status.should == 401
  end

  it "grants access" do
    get "/v1/", {}, "HTTP_AUTHORIZATION" => basic_auth("admin", "test")

    last_response.status.should == 200
    JSON.load(last_response.body).should == {"success" => true}
  end
end
