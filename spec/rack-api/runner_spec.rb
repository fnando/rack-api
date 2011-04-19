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
    subject.option(:formats).should == [:json, :jsonp, :atom]
  end

  it "sets prefix option" do
    subject.prefix("my/awesome/api")
    subject.option(:prefix).should == "my/awesome/api"
  end

  it "stores default url options" do
    subject.default_url_options(:host => "example.com")
    subject.option(:url_options).should == {:host => "example.com"}
  end

  it "stores middleware" do
    subject.use Rack::Auth::Basic
    subject.option(:middlewares, :merge).should == [[Rack::Auth::Basic]]
  end

  it "stores basic auth info" do
    handler = proc {}

    subject.basic_auth("Get out!", &handler)
    subject.settings[:global][:auth].should == ["Get out!", handler]
  end
end
