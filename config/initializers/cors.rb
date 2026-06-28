# Allow the bonus landing page (and other local frontends) to call the API.
# public/index.html fetches GET /listings from the same or a different origin.
Rails.application.config.middleware.insert_before 0, Rack::Cors do  allow do
    origins(
      "localhost:3000",
      "localhost:5173",
      "localhost:5500",
      "localhost:8080",
      "127.0.0.1:3000",
      "127.0.0.1:5173",
      "127.0.0.1:5500",
      "127.0.0.1:8080"
    )

    resource "*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ]
  end
end
