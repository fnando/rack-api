class MyController < Rack::API::Controller
  def index
    {:name => params[:name]}
  end
end
