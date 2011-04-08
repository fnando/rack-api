require "spec_helper"

describe Rack::API, "Basic Authentication" do
   before do
    Rack::API.app do
      basic_auth do |user, pass|
        user == "admin" && pass == "test"
      end

      version :v1 do
        get("/") { {:success => true} }
      end

      version :v2 do
        basic_auth :none
        get("/") { {:success => true} }
        get("/credentials") { credentials }
      end

      version :v3 do
        basic_auth do |user, pass|
          user == "john" && pass == "test"
        end

        get("/") { {:success => true} }
      end
    end
  end

  context "global authorization" do
    it "denies access" do
      get "/v1/"
      last_response.status.should == 401

      get "/v1/", {}, "HTTP_AUTHORIZATION" => basic_auth("admin", "invalid")
      last_response.status.should == 401

      get "/v1/", {}, "HTTP_AUTHORIZATION" => basic_auth("john", "test")
      last_response.status.should == 401
    end

    it "grants access" do
      get "/v1/", {}, "HTTP_AUTHORIZATION" => basic_auth("admin", "test")

      last_response.status.should == 200
      last_response.body.should == {"success" => true}.to_json
    end
  end

  context "no authorization" do
    it "grants access" do
      get "/v2/"

      last_response.status.should == 200
      last_response.body.should == {"success" => true}.to_json
    end
  end

  context "local authorization" do
    it "denies access" do
      get "/v3/"
      last_response.status.should == 401

      get "/v3/", {}, "HTTP_AUTHORIZATION" => basic_auth("admin", "test")
      last_response.status.should == 401
    end

    it "grants access" do
      get "/v3/", {}, "HTTP_AUTHORIZATION" => basic_auth("john", "test")

      last_response.status.should == 200
      last_response.body.should == {"success" => true}.to_json
    end
  end

  it "returns credentials" do
    get "/v2/credentials", {}, "HTTP_AUTHORIZATION" => basic_auth("admin", "test")
    last_response.body.should == ["admin", "test"].to_json
  end

  it "returns empty array when no credentials are provided" do
    get "/v2/credentials"
    last_response.body.should == [].to_json
  end
end
