class MyApp < Rack::API
  version :v1 do
    get "/" do
      {:myapp => true}
    end
  end
end
