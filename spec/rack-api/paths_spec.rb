require "spec_helper"

describe Rack::API, "Paths" do
   before do
    Rack::API.app do
      version :v1 do
        prefix "api"
        get("users") { {:users => []} }
      end

      version :v2 do
        prefix "/"
        get("users") { {:users => []} }
      end
    end
  end

  it "does not render root" do
    get "/"
    last_response.status.should == 404
  end

  it "does not render unknown paths" do
    get "/api/v1/users/index"
    last_response.status.should == 404
  end

  it "renders known paths" do
    get "/api/v1/users"
    last_response.status.should == 200

    get "/v2/users"
    last_response.status.should == 200
  end
end
