require "spec_helper"

describe Rack::API::Middleware::SSL do
  let(:action) { proc {|env| [200, {}, ["success"]] } }

  it "denies http requests" do
    env = Rack::MockRequest.env_for("/v1", "rack.url_scheme" => "http")
    status, headers, response = Rack::API::Middleware::SSL.new(action).call(env)

    status.should == 400
    headers["Content-Type"].should == "text/plain"
    response.should include("Only HTTPS requests are supported by now.")
  end

  it "accepts https requests" do
    env = Rack::MockRequest.env_for("/v1", "rack.url_scheme" => "https")
    status, headers, response = Rack::API::Middleware::SSL.new(action).call(env)

    status.should == 200
  end
end
