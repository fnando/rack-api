require "spec_helper"

describe Rack::API, "delegators" do
  subject { Rack::API }

  specify "sanity check for delegate methods" do
    Rack::API::Runner::DELEGATE_METHODS.size.should == 15
  end

  it { should respond_to(:version) }
  it { should respond_to(:use) }
  it { should respond_to(:prefix) }
  it { should respond_to(:basic_auth) }
  it { should respond_to(:helper) }
  it { should respond_to(:default_url_options) }
  it { should respond_to(:rescue_from) }
  it { should respond_to(:get) }
  it { should respond_to(:post) }
  it { should respond_to(:put) }
  it { should respond_to(:delete) }
  it { should respond_to(:head) }
  it { should respond_to(:patch) }
  it { should respond_to(:options) }
end
