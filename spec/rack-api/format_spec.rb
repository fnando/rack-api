require "spec_helper"

describe Rack::API, "Format" do
   before do
    Rack::API.app do
      version :v1 do
        respond_to :json, :jsonp, :awesome, :fffuuu, :zomg
        get("/") { {:success => true} }
        get("users(.:format)") { {:users => []} }
      end
    end
  end

  it "ignores unknown paths/formats" do
    get "/users.xml"
    last_response.status.should == 404
  end

  context "missing formatter" do
    it "renders 406" do
      get "/v1/users.zomg"

      last_response.status.should == 406
      last_response.body.should == "Unknown format"
      last_response.headers["Content-Type"].should == "text/plain"
    end
  end

  context "default format" do
    it "is json" do
      Rack::API.app do
        version :v2 do
          get("/") { {:success => true} }
        end
      end

      get "/v2"
      last_response.headers["Content-Type"].should == "application/json"
    end

    it "is set to the first respond_to value" do
      Rack::API::App::MIME_TYPES["fffuuu"] = "application/x-fffuuu"

      Rack::API.app do
        version :v2 do
          respond_to :fffuuu, :json
          get("/") { OpenStruct.new(:to_fffuuu => "Fffuuu") }
        end
      end

      get "/v2"
      last_response.headers["Content-Type"].should == "application/x-fffuuu"
    end
  end

  context "invalid format" do
    it "renders 406" do
      get "/v1/users.invalid"

      last_response.status.should == 406
      last_response.body.should == "Invalid format. Accepts one of [json, jsonp, awesome, fffuuu, zomg]"
      last_response.headers["Content-Type"].should == "text/plain"
    end
  end

  context "JSONP" do
    it "renders when set through query string" do
      get "/v1", :format => "jsonp"

      last_response.status.should == 200
      last_response.body.should == %[callback({"success":true});]
    end

    it "renders when set through extension" do
      get "/v1/users.jsonp"

      last_response.status.should == 200
      last_response.body.should == %[callback({"users":[]});]
    end

    it "sends header" do
      get "/v1/users.jsonp"
      last_response.headers["Content-Type"].should == "application/javascript"
    end
  end

  context "JSON" do
    it "renders when set through query string" do
      get "/v1", :format => "json"

      last_response.status.should == 200
      last_response.body.should == {"success" => true}.to_json
    end

    it "renders when set through extension" do
      get "/v1/users.json"

      last_response.status.should == 200
      last_response.body.should == {"users" => []}.to_json
    end

    it "sends header" do
      get "/v1/users.json"
      last_response.headers["Content-Type"].should == "application/json"
    end
  end

  context "custom formatter extension" do
    it "renders when set through query string" do
      get "/v1", :format => "awesome"

      last_response.status.should == 200
      last_response.body.should == "U R Awesome"
    end

    it "renders when set through extension" do
      get "/v1/users.awesome"

      last_response.status.should == 200
      last_response.body.should == "U R Awesome"
    end
  end

  context "custom formatter class" do
    before :all do
      Rack::API::Formatter::Fffuuu = Class.new(Rack::API::Formatter::Base) do
        def to_format
          "ZOMG! Fffuuu!"
        end
      end
    end

    it "renders when set through query string" do
      get "/v1", :format => "fffuuu"

      last_response.status.should == 200
      last_response.body.should == "ZOMG! Fffuuu!"
    end

    it "renders when set through extension" do
      get "/v1/users.fffuuu"

      last_response.status.should == 200
      last_response.body.should == "ZOMG! Fffuuu!"
    end
  end
end
