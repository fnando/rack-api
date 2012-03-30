require "spec_helper"

describe Rack::API, "separators" do
   before do
    Rack::API.app do
      get("/no-dots/:name(.:format)") { params }
      get("/dots/:name", :separator => %w[/?]) { params }
    end
  end

  context "/no-dots/:name" do
    it "stops on /" do
      get "/no-dots/foo/"
      last_response.body.should == {:name => "foo"}.to_json
    end

    it "stops on ?" do
      get "/no-dots/foo?a=1"
      last_response.body.should == {:a => "1", :name => "foo"}.to_json
    end

    it "stops on ." do
      get "/no-dots/foo.json"
      last_response.body.should == {:name => "foo", :format => "json"}.to_json
    end
  end

  context "/dots/:name" do
    it "stops on /" do
      get "/dots/foo/"
      last_response.body.should == {:name => "foo"}.to_json
    end

    it "stops on ?" do
      get "/dots/foo?a=1"
      last_response.body.should == {:a => "1", :name => "foo"}.to_json
    end

    it "stops on ." do
      get "/dots/foo.json"
      last_response.body.should == {:name => "foo.json"}.to_json
    end
  end
end
