require "spec_helper"

describe Rack::API, "HTTP Methods" do
   before do
    Rack::API.app do
      version :v1 do
        get("get") { {:get => true} }
        post("post") { {:post => true} }
        put("put") { {:put => true} }
        delete("delete") { {:delete => true} }
        head("head") { {:head => true} }
      end
    end
  end

  Rack::API::Runner::HTTP_METHODS.each do |method|
    it "renders #{method}" do
      send method, "/v1/#{method}"
      last_response.status.should == 200
      JSON.load(last_response.body).should == {method => true}
    end
  end

  it "does not render unknown methods" do
    post "/get"
    last_response.status.should == 404
  end
end
