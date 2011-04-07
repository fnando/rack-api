class AwesomeMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)
    [status, headers.merge("X-Awesome" => "U R Awesome"), response]
  end
end
