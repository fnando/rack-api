require "spec_helper"

describe Rack::API::Runner, "Settings" do
  it "uses global namespace when no version is defined" do
    subject.set :foo, :bar
    subject.settings[:global][:foo].should == :bar
  end

  it "uses local namespace when version is defined" do
    subject.settings[:version] = "v1"
    subject.set :foo, :bar

    subject.settings[:foo].should == :bar
  end

  it "appends item when mode is :append" do
    subject.settings[:global][:list] = []
    subject.set :list, :item, :append

    subject.settings[:global][:list].should == [:item]
  end

  it "overrides item when mode is :override" do
    subject.settings[:global][:list] = []
    subject.set :list, [:item], :override

    subject.settings[:global][:list].should == [:item]
  end

  it "returns global value" do
    subject.set :name, "John Doe"
    subject.option(:name).should == "John Doe"
  end

  it "returns local value" do
    subject.settings[:version] = "v1"
    subject.set :name, "John Doe"

    subject.option(:name).should == "John Doe"
  end

  it "prefers local setting over global one" do
    subject.set :name, "Mary Doe"

    subject.settings[:version] = "v1"
    subject.set :name, "John Doe"

    subject.option(:name).should == "John Doe"
  end
end
