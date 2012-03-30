require "spec_helper"

describe Rack::API::Runner do
  specify "sanity check for delegate methods" do
    # remember to update spec/method_delegation_spec.rb
    Rack::API::Runner::DELEGATE_METHODS.size.should == 13
  end

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

  it "initializes application with correct parameters" do
    expected = {
      :version => "v1",
      :url_options => {:host => "mysite.com"},
      :default_format => "fffuuu",
      :prefix => "api",
      :handler => proc {}
    }

    Rack::API::Controller
      .should_receive(:new)
      .with(hash_including(expected))
      .and_return(mock.as_null_object)

    subject.version("v1") do
      respond_to :fffuuu
      prefix "api"
      default_url_options :host => "mysite.com"

      get("/", &expected[:handler])
    end
  end
end
