module Helpers
  def app
    @app ||= Rack::API
  end

  def basic_auth(username, password)
    "Basic " + Base64.encode64("#{username}:#{password}")
  end
end
