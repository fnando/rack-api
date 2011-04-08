module Helpers
  def app
    @app ||= Rack::API
  end

  def basic_auth(username, password)
    "Basic " + Base64.encode64("#{username}:#{password}")
  end

  def json(string)
    JSON.load(string)
  end
end
