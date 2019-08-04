defmodule ThundermoonWeb.Router do
  use ThundermoonWeb, :router
  use Plugsnag

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ThundermoonWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/dashboard", PageController, :dashboard

    get "/auth/github", AuthController, :request
    get "/auth/github/callback", AuthController, :callback
    delete "/auth", AuthController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", ThundermoonWeb do
  #   pipe_through :api
  # end
end
