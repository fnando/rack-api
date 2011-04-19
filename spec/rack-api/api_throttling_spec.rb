require "spec_helper"

describe Rack::API::Middleware::Limit do
  let(:action) { proc {|env| [200, {}, ["success"]] } }
  let(:env) {
    Rack::MockRequest.env_for("/v1",
      "REMOTE_ADDR"        => "127.0.0.1",
      "X-API_KEY"          => "fo7hy7ra",
      "HTTP_AUTHORIZATION" => basic_auth("admin", "test")
    )
  }

  subject { Rack::API::Middleware::Limit.new(action) }

  before do
    Time.stub :now => Time.parse("2011-04-08 00:00:00")
    @stamp = Time.now.strftime("%Y%m%d%H")

    begin
      $redis = Redis.new
      $redis.del "api:127.0.0.1:#{@stamp}"
      $redis.del "api:fo7hy7ra:#{@stamp}"
      $redis.del "api:admin:#{@stamp}"
      $redis.del "api:whitelist"
      subject.options.merge!(:with => $redis)
    # rescue Exception => e
      pending "Redis is not running"
    end
  end

  context "using default options" do
    it "renders action when limit wasn't exceeded" do
      results = 60.times.collect { subject.call(env) }

      $redis.get("api:127.0.0.1:#{@stamp}").to_i.should == 60
      results.last[0].should == 200
    end

    it "renders 503 when limit was exceeded" do
      results = 61.times.collect { subject.call(env) }

      $redis.get("api:127.0.0.1:#{@stamp}").to_i.should == 61
      results.last[0].should == 503
    end
  end

  context "using custom options" do
    it "respects limit" do
      subject.options.merge!(:limit => 20)

      results = 20.times.collect { subject.call(env) }

      $redis.get("api:127.0.0.1:#{@stamp}").to_i.should == 20
      results.last[0].should == 200
    end

    it "uses custom string key" do
      subject.options.merge!(:key => "X-API_KEY")
      status, headers, result = subject.call(env)

      $redis.get("api:fo7hy7ra:#{@stamp}").to_i.should == 1
      status.should == 200
    end

    it "uses custom block key" do
      subject.options.merge! :key => proc {|env|
        request = Rack::Auth::Basic::Request.new(env)
        request.credentials[0]
      }

      status, headers, result = subject.call(env)

      $redis.get("api:admin:#{@stamp}").to_i.should == 1
      status.should == 200
    end
  end

  context "whitelist" do
    it "bypasses API limit" do
      $redis.sadd("api:whitelist", "127.0.0.1")

      subject.options.merge!(:limit => 5)
      results = 10.times.collect { subject.call(env) }

      $redis.get("api:127.0.0.1:#{@stamp}").to_i.should == 10
      results.last[0].should == 200
    end
  end
end
