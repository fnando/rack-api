require "spec_helper"

describe Rack::API::Runner do
  it "responds to http methods" do
    subject.should respond_to(:get)
    subject.should respond_to(:post)
    subject.should respond_to(:put)
    subject.should respond_to(:delete)
    subject.should respond_to(:head)
  end

  it "sets available formats" do
    subject.respond_to(:json, :jsonp, :atom)
    subject.settings[:formats].should == [:json, :jsonp, :atom]
  end

  it "sets prefix option" do
    subject.prefix("my/awesome/api")
    subject.settings[:prefix].should == "my/awesome/api"
  end

  it "considers prefix and version when building paths" do
    subject.settings.merge!(:prefix => "api", :version => "v1")
    subject.mount_path("users").should == "/api/v1/users"
  end

  it "stores middleware" do
    subject.use Rack::Auth::Basic
    subject.settings[:middlewares].should == [[Rack::Auth::Basic]]
  end

  it "stores basic auth info" do
    handler = proc {}

    subject.basic_auth("Get out!", &handler)
    subject.settings[:auth].should == ["Get out!", handler]
  end
end
