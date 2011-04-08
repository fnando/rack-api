class ZOMGMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)
    [status, headers.merge("X-ZOMG" => "ZOMG!"), response]
  end
end
