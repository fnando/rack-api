require "spec_helper"

describe Rack::API::Controller, "#url_for" do
  subject { Rack::API::Controller.new(
    :version => "v1",
    :url_options => {},
    :env => Rack::MockRequest.env_for("/v1")
  )}

  it "returns url considering prefix" do
    subject.prefix = "api"
    subject.url_for.should == "http://example.org/api/v1"
  end

  it "ignores prefix when is not set" do
    subject.prefix = nil
    subject.url_for.should == "http://example.org/v1"
  end

  it "returns host" do
    subject.url_for.should == "http://example.org/v1"
  end

  it "sets default url options hash" do
    subject = Rack::API::Controller.new(:version => "v1", :url_options => nil, :env => Rack::MockRequest.env_for("/v1"))

    expect {
      subject.url_for(:things, 1)
    }.to_not raise_error
  end

  it "uses a different host" do
    subject.url_options.merge!(:host => "mysite.com")
    subject.url_for.should == "http://mysite.com/v1"
  end

  it "uses a different protocol" do
    subject.url_options.merge!(:protocol => "https")
    subject.url_for.should == "https://example.org/v1"
  end

  it "uses a different port" do
    subject.url_options.merge!(:port => "2345")
    subject.url_for.should == "http://example.org:2345/v1"
  end

  it "uses #to_param when available" do
    subject.url_for("users", mock(:user, :to_param => "1-john-doe")).should == "http://example.org/v1/users/1-john-doe"
  end

  it "converts other data types" do
    subject.url_for(:users, 1).should == "http://example.org/v1/users/1"
  end

  it "adds query string" do
    actual = subject.url_for(:format => :json, :filters => [:name, :age])
    actual.should == "http://example.org/v1?filters[]=name&filters[]=age&format=json"
  end

  it "uses host from request" do
    env = Rack::MockRequest.env_for("/v1", "SERVER_NAME" => "mysite.com")
    subject = Rack::API::Controller.new(:version => "v1", :env => env)
    subject.url_for.should == "http://mysite.com/v1"
  end

  it "uses port from request" do
    env = Rack::MockRequest.env_for("/v1", "SERVER_PORT" => "2345")
    subject = Rack::API::Controller.new(:version => "v1", :env => env)
    subject.url_for.should == "http://example.org:2345/v1"
  end
end
