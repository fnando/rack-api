require "spec_helper"

describe Rack::API do
  before do
    Rack::API.app do
      get("/", :to => "my_controller#index")
    end
  end

  it "renders action from MyApp" do
    get "/", :name => "John"
    last_response.body.should == {"name" => "John"}.to_json
  end
end
